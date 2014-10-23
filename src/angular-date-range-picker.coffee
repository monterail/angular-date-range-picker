angular.module "dateRangePicker", []

angular.module("dateRangePicker").directive "dateRangePicker", ["$compile", "$timeout", ($compile, $timeout) ->
  # constants
  pickerTemplate = """
  <div ng-show="visible" class="angular-date-range-picker__picker" ng-click="handlePickerClick($event)" ng-class="{'angular-date-range-picker--ranged': showRanged }">
    <div class="angular-date-range-picker__timesheet">
      <a ng-click="move(-1, $event)" class="angular-date-range-picker__prev-month">&#9664;</a>
      <div ng-repeat="month in months" class="angular-date-range-picker__month">
        <div class="angular-date-range-picker__month-name">{{::month.name}}</div>
        <table class="angular-date-range-picker__calendar">
          <tr>
            <th ng-repeat="day in month.weeks[1]" class="angular-date-range-picker__calendar-weekday">{{::dat.date.format('dd')}}</th>
          </tr>
          <tr ng-repeat="week in month.weeks">
            <td
                ng-class='{
                  "angular-date-range-picker__calendar-day": day,
                  "angular-date-range-picker__calendar-day-selected": day.selected,
                  "angular-date-range-picker__calendar-day-disabled": day.disabled,
                  "angular-date-range-picker__calendar-day-start": day.start
                }'
                ng-repeat="day in week track by $index" ng-click="select(day, $event)">
                <div class="angular-date-range-picker__calendar-day-wrapper">{{::day.date.date()}}</div>
            </td>
          </tr>
        </table>
      </div>
      <a ng-click="move(+1, $event)" class="angular-date-range-picker__next-month">&#9654;</a>
    </div>
    <div class="angular-date-range-picker__panel">
      <div ng-show="showRanged">
        Select range: <select ng-click="prevent_select($event)" ng-model="quick" ng-options="e.range as e.label for e in quickList"></select>
      </div>
      <div class="angular-date-range-picker__buttons">
        <a ng-click="ok($event)" class="angular-date-range-picker__apply">Apply</a>
        <a ng-click="hide($event)" class="angular-date-range-picker__cancel">cancel</a>
      </div>
    </div>
  </div>
  """
  CUSTOM = "CUSTOM"

  restrict: "AE"
  replace: true
  template: """
  <span tabindex="0" ng-keydown="hide()" class="angular-date-range-picker__input">
    <span ng-if="showRanged">
      <span ng-show="!!model">{{ model.start.format("ll") }} - {{ model.end.format("ll") }}</span>
      <span ng-hide="!!model">Select date range</span>
    </span>
    <span ng-if="!showRanged">
      <span ng-show="!!model">{{ model.format("ll") }}</span>
      <span ng-hide="!!model">Select date</span>
    </span>
  </span>
  """
  scope:
    model: "=ngModel" # can't use ngModelController, we need isolated scope
    customSelectOptions: "="
    ranged: "="
    pastDates: "@"
    callback: "&"

  link: ($scope, element, attrs) ->
    $scope.quickListDefinitions = $scope.customSelectOptions
    $scope.quickListDefinitions ?= [
      {
        label: "This week",
        range: moment().range(
          moment().startOf("week").startOf("day"),
          moment().endOf("week").startOf("day")
        )
      }
      {
        label: "Next week",
        range: moment().range(
          moment().startOf("week").add(1, "week").startOf("day"),
          moment().add(1, "week").endOf("week").startOf("day")
        )
      }
      {
        label: "This fortnight",
        range: moment().range(
          moment().startOf("week").startOf("day"),
          moment().add(1, "week").endOf("week").startOf("day")
        )
      }
      {
        label: "This month",
        range: moment().range(
          moment().startOf("month").startOf("day"),
          moment().endOf("month").startOf("day")
        )
      }
      {
        label: "Next month",
        range: moment().range(
          moment().startOf("month").add(1, "month").startOf("day"),
          moment().add(1, "month").endOf("month").startOf("day")
        )
      }
    ]
    $scope.quick = null
    $scope.range = null
    $scope.selecting = false
    $scope.visible = false
    $scope.start = null
    # Backward compatibility - if $scope.ranged is not set in the html, it displays normal date range picker.
    $scope.showRanged = if $scope.ranged == undefined then true else $scope.ranged

    _makeQuickList = (includeCustom = false) ->
      return unless $scope.showRanged
      $scope.quickList = []
      $scope.quickList.push(label: "Custom", range: CUSTOM) if includeCustom
      for e in $scope.quickListDefinitions
        $scope.quickList.push(e)

    _calculateRange = () ->
      if $scope.showRanged
        $scope.range = if $scope.selection
          start = $scope.selection.start.clone().startOf("month").startOf("day")
          end = start.clone().add(2, "months").endOf("month").startOf("day")
          moment().range(start, end)
        else
          moment().range(
            moment().startOf("month").subtract(1, "month").startOf("day"),
            moment().endOf("month").add(1, "month").startOf("day")
          )
      else
        $scope.selection = false
        $scope.selection = $scope.model || false
        $scope.date = moment($scope.model) || moment()
        $scope.range = moment().range(
          moment($scope.date).startOf("month"),
          moment($scope.date).endOf("month")
        )

    _checkQuickList = () ->
      return unless $scope.showRanged
      return unless $scope.selection
      for e in $scope.quickList
        if e.range != CUSTOM and $scope.selection.start.startOf("day").unix() == e.range.start.startOf("day").unix() and
            $scope.selection.end.startOf("day").unix() == e.range.end.startOf("day").unix()
          $scope.quick = e.range
          _makeQuickList()
          return

      $scope.quick = CUSTOM
      _makeQuickList(true)


    _prepare = () ->
      $scope.months = []
      startIndex = $scope.range.start.year()*12 + $scope.range.start.month()
      startDay = moment().startOf("week").day()

      $scope.range.by "days", (date) ->
        d = date.day() - startDay
        d = 7+d if d < 0 # (d == -1 fix for sunday)
        m = date.year()*12 + date.month() - startIndex
        w = parseInt((7 + date.date() - d) / 7)

        sel = false
        dis = false

        if $scope.showRanged
          if $scope.start
            sel = date == $scope.start
            dis = date < $scope.start
          else
            sel = $scope.selection && $scope.selection.contains(date)
        else
          sel = date.isSame($scope.selection)
          dis = moment().diff(date, 'days') > 0 if $scope.pastDates

        $scope.months[m] ||= {name: date.format("MMMM YYYY"), weeks: []}
        $scope.months[m].weeks[w] ||= []
        $scope.months[m].weeks[w][d] =
          date:     date
          selected: sel
          disabled: dis
          start:    ($scope.start && $scope.start.unix() == date.unix())

      # Remove empty rows
      for m in $scope.months
        if !m.weeks[0]
          m.weeks.splice(0, 1)

      _checkQuickList()

    $scope.show = () ->
      $scope.selection = $scope.model
      _calculateRange()
      _prepare()
      $scope.visible = true

    $scope.hide = ($event) ->
      $event?.stopPropagation?()
      $scope.visible = false
      $scope.start = null

    $scope.prevent_select = ($event) ->
      $event?.stopPropagation?()


    $scope.ok = ($event) ->
      $event?.stopPropagation?()
      $scope.model = $scope.selection
      $timeout -> $scope.callback() if $scope.callback
      $scope.hide()

    $scope.select = (day, $event) ->
      $event?.stopPropagation?()
      return if day.disabled

      if $scope.showRanged
        $scope.selecting = !$scope.selecting

        if $scope.selecting
          $scope.start = day.date
        else
          $scope.selection = moment().range($scope.start, day.date)
          $scope.start = null
      else
        $scope.selection = moment(day.date)

      _prepare()

    $scope.move = (n, $event) ->
      $event?.stopPropagation?()
      if $scope.showRanged
        $scope.range = moment().range(
          $scope.range.start.add(n, 'months').startOf("month").startOf("day"),
          $scope.range.start.clone().add(2, "months").endOf("month").startOf("day")
        )
      else
        $scope.date.add(n, 'months')
        $scope.range = moment().range(
          moment($scope.date).startOf("month"),
          moment($scope.date).endOf("month")
        )

      _prepare()

    $scope.handlePickerClick = ($event) ->
      $event?.stopPropagation?()

    $scope.$watch "quick", (q, o) ->
      return if !q || q == CUSTOM
      $scope.selection = $scope.quick
      $scope.selecting = false
      $scope.start = null
      _calculateRange()
      _prepare()

    $scope.$watch "customSelectOptions", (value) ->
      return unless customSelectOptions?
      $scope.quickListDefinitions = value

    # create DOM and bind event
    domEl = $compile(angular.element(pickerTemplate))($scope)
    element.append(domEl)

    element.bind "click", (e) ->
      e?.stopPropagation?()
      $scope.$apply ->
        if $scope.visible then $scope.hide() else $scope.show()

    documentClickFn = (e) ->
      $scope.$apply -> $scope.hide()
      true

    angular.element(document).bind "click", documentClickFn

    $scope.$on '$destroy', ->
      angular.element(document).unbind 'click', documentClickFn

    _makeQuickList()
    _calculateRange()
    _prepare()
]
