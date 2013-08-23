angular.module "dateRangePicker", []

angular.module("dateRangePicker").directive "dateRangePicker", ($compile) ->
  # constants
  pickerTemplate = """
  <div ng-show="visible" class="angular-date-range-picker_picker">
    <button ng-click="move(-1, $event)" class="angular-date-range-picker_picker_prev-month"><</button>
    <div ng-repeat="month in months" class="angular-date-range-picker_picker_month">
      <div class="angular-date-range-picker_picker_month_name">{{ month.name }}</div>
      <table class="angular-date-range-picker_picker_calendar">
        <tr>
          <th ng-repeat="day in month.weeks[1]" class="angular-date-range-picker_picker_calendar_weekday">
            {{ day.date.format("dd") }}
          </th>
        </tr>
        <tr ng-repeat="week in month.weeks">
          <td class="angular-date-range-picker_picker_calendar_day" ng-class='{"angular-date-range-picker_picker_calendar_day_selected": day.selected, "angular-date-range-picker_picker_calendar_day_disabled": day.disabled}' ng-repeat="day in week" ng-click="select(day, $event)">
            {{ day.date.date() }}
          </td>
        </tr>
      </table>
    </div>
    <button ng-click="move(+1, $event)" class="angular-date-range-picker_picker_next-month">></button>
    <div class=" class="angular-date-range-picker_picker_panel">
      Select range: <select ng-model="quick" ng-options="e.range as e.label for e in quickList"></select>
      <button ng-click="ok($event)">Apply</button>
      <a href="#" ng-click="hide($event)" class="angular-date-range-picker_picker_close">close</a>
    </div>
  </div>
  """
  oneDayRange = moment().range("2013-01-01", "2013-01-02")

  restrict: "AE"
  replace: true
  template: """
  <span class="angular-date-range-picker_input">
    <span ng-show="model">{{ model.start.format("ll") }} - {{ model.end.format("ll") }}</span>
    <span ng-hide="model">Select date range</span>
  </span>
  """
  scope:
    model: "=ngModel" # can't use ngModelController, we need isolated scope

  link: ($scope, element, attrs) ->
    $scope.quickList = [
      {label: "This week",  range: moment().range(moment().startOf("week"), moment().endOf("week"))}
      {label: "Next week",  range: moment().range(moment().startOf("week").add(1, "week"), moment().endOf("week").add(1, "week"))}
      {label: "This month", range: moment().range(moment().startOf("month"), moment().endOf("month"))}
      {label: "Next month", range: moment().range(moment().startOf("month").add(1, "month"), moment().endOf("month").add(1, "month"))}
    ]
    $scope.quick = null
    $scope.range = null
    $scope.selecting = false
    $scope.visible = false
    $scope.start = null

    _calculateRange = () ->
      $scope.range = if $scope.selection
        start = $scope.selection.start.clone().startOf("month").startOf("day")
        end = start.clone().add(2, "months").endOf("month").startOf("day")
        moment().range(start, end)
      else
        moment().range(
          moment().startOf("month").subtract(1, "month").startOf("day"),
          moment().endOf("month").add(1, "month").startOf("day")
        )

    _prepare = () ->
      $scope.months = []
      startIndex = $scope.range.start.year()*12 + $scope.range.start.month()

      $scope.range.by oneDayRange, (date) ->
        m = date.year()*12 + date.month() - startIndex
        w = parseInt((7 + date.date() - date.day()) / 7)
        d = date.day()

        sel = false
        dis = false

        if $scope.start
          sel = date == $scope.start
          dis = date < $scope.start
        else
          sel = $scope.selection && $scope.selection.contains(date)

        $scope.months[m] ||= {name: date.format("MMMM YYYY"), weeks: []}
        $scope.months[m].weeks[w] ||= []
        $scope.months[m].weeks[w][d] =
          date:     date
          selected: sel
          disabled: dis

      # Remove empty rows
      for m in $scope.months
        if !m.weeks[0]
          m.weeks.splice(0, 1)

    $scope.show = () ->
      $scope.visible = true

    $scope.hide = ($event) ->
      $event?.stopPropagation?()
      $scope.visible = false

    $scope.ok = ($event) ->
      $event?.stopPropagation?()
      $scope.model = $scope.selection
      $scope.hide()

    $scope.select = (day, $event) ->
      $event?.stopPropagation?()
      return if day.disabled

      $scope.selecting = !$scope.selecting

      if $scope.selecting
        $scope.start = day.date
        _prepare()
      else
        $scope.selection = moment().range($scope.start, day.date)
        $scope.start = null
        _prepare()

    $scope.move = (n, $event) ->
      $event?.stopPropagation?()
      $scope.range = moment().range(
        $scope.range.start.add(n, 'months').startOf("month").startOf("day"),
        $scope.range.start.clone().add(2, "months").endOf("month").startOf("day")
      )
      _prepare()

    $scope.$watch "quick", (q, o) ->
      return unless q
      $scope.selection = $scope.quick
      _calculateRange()
      _prepare()

    $scope.$watch "model", (s,o) ->
      return if !s
      $scope.selection = $scope.model
      _calculateRange()
      _prepare()

    # create DOM and bind event
    domEl = $compile(angular.element(pickerTemplate))($scope)
    element.append(domEl)

    element.bind "click", (e) ->
      e?.stopPropagation?()
      $scope.$apply ->
        if $scope.visible then $scope.hide() else $scope.show()


    angular.element(document).bind "click", (e) ->
      $scope.$apply -> $scope.hide()

    _calculateRange()
    _prepare()

