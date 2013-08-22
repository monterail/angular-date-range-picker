angular.module "datepicker", []

angular.module("datepicker").directive "datepicker", ($compile) ->
  template = """
  <div>
    <a href="#" ng-click="close()">close</a>
    <div ng-repeat="month in months" class="month">
      {{ month.name }}
      <table>
        <tr ng-repeat="week in month.weeks">
          <td class="day" ng-class="{selected: day.selected}" ng-repeat="day in week" ng-click="select(day)">
            {{ day.date.date() }}
          </td>
        </tr>
      </table>
    </div>
    <select ng-model="quick" ng-options="e.range as e.label for e in quickList"></select>
  </div>
  """

  restrict: "A"
  replace: true
  scope:
    dates: "=ngModel"
  link: (scope, element, attrs, controller) ->
    range = null
    domEl = null
    oneDayRange = moment().range(moment("2013-01-01"), moment("2013-01-02"))

    scope.quick = null
    scope.quickList = [
      {label: "This week",  range: moment().range(moment().startOf("week"), moment().endOf("week"))}
      {label: "Next week",  range: moment().range(moment().startOf("week").add(1, "week"), moment().endOf("week").add(1, "week"))}
      {label: "This month", range: moment().range(moment().startOf("month"), moment().endOf("month"))}
      {label: "Next month", range: moment().range(moment().startOf("month").add(1, "month"), moment().endOf("month").add(1, "month"))}
    ]

    setup = () ->
      start = scope.selection.start.clone().startOf("month").startOf("day")
      end = start.clone().add(2, "months").endOf("month").startOf("day")
      range = moment().range(start, end)

    prepareData = () ->
      scope.months = []
      startIndex = range.start.year()*12 + range.start.month()

      range.by oneDayRange, (date) ->
        m = date.year()*12 + date.month() - startIndex
        w = parseInt((7 + date.date() - date.day()) / 7)
        d = date.day()
        s = scope.selection.contains(date)
        scope.months[m] ||= {name: date.format("MMMM YYYY"), weeks: []}
        scope.months[m].weeks[w] ||= []
        scope.months[m].weeks[w][d] = {date: date, selected: s}

      # Remove empty rows
      for m in scope.months
        if !m.weeks[0]
          m.weeks.splice(0, 1)

    scope.selecting = false
    scope.opened = false

    scope.select = (day) ->
      scope.selecting = !scope.selecting

      if scope.selecting
        scope.selection = moment().range(day.date, day.date)
      else
        scope.selection = moment().range(scope.selection.start, day.date)
        scope.dates = [scope.selection.start.toDate(), day.date.toDate()]
      prepareData()


    scope.close = () ->
      domEl.remove()
      scope.opened = false

    scope.$watch "dates", ->
      scope.selection = moment().range(scope.dates[0], scope.dates[1])
      setup()
      prepareData()

    scope.$watch "quick", (q, o) ->
      return unless q
      scope.selection = scope.quick
      setup()
      prepareData()

    display = () ->
      domEl = $compile(angular.element(template))(scope)
      body = angular.element(document.body)
      body.append(domEl)

    scope.open = () ->
      scope.selection = moment().range(scope.dates[0], scope.dates[1])
      setup()
      prepareData()
      display()
      scope.opened = true

    element.bind "click", ->
      scope.$apply ->
        if scope.opened then scope.close() else scope.open()

