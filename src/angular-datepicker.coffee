angular.module "datepicker", []

angular.module("datepicker").directive "datepicker", ($compile) ->
  template = """
  <div>
    <a href="#" ng-click="close()">close</a>
    <div ng-repeat="month in _picker.months" class="month">
      {{ month.name }}
      <table>
        <tr ng-repeat="week in month.weeks">
          <td class="day" ng-class="{selected: day.selected}" ng-repeat="day in week" ng-click="select(day)">
            {{ day.date.date() }}
          </td>
        </tr>
      </table>
    </div>
  </div>
  """

  restrict: "A"
  replace: true
  scope:
    dates: "=ngModel"
  link: (scope, element, attrs, controller) ->
    window.s = scope
    console.log "dates", scope.dates

    selection = null
    range = null
    domEl = null
    oneDayRange = moment().range(moment("2013-01-01"), moment("2013-01-02"))

    scope._picker = {}

    setup = () ->
      selection = moment().range(scope.dates[0], scope.dates[1])
      end = moment(scope.dates[1]).endOf("month")
      range = moment().range(end.clone().subtract(3, "months").add(1, "day"), end)

    prepareData = () ->
      startMonth = range.start.month()
      scope._picker.months = []

      range.by oneDayRange, (date) ->
        m = date.month() - startMonth
        w = parseInt((7 + date.date() - date.day()) / 7)
        d = date.day()
        s = selection.contains(date)
        scope._picker.months[m] ||= {name: date.format("MMMM YYYY"), weeks: []}
        scope._picker.months[m].weeks[w] ||= []
        scope._picker.months[m].weeks[w][d] = {date: date, selected: s}

      # Remove empty rows
      for m in scope._picker.months
        if !m.weeks[0]
          m.weeks.splice(0, 1)

    scope.selecting = false
    scope.select = (day) ->
      scope.selecting = !scope.selecting

      if scope.selecting
        selection = moment().range(day.date, day.date)
      else
        selection = moment().range(selection.start, day.date)
        scope.dates = [selection.start.toDate(), day.date.toDate()]
      prepareData()

    scope.close = () ->
      domEl.remove()

    display = () ->
      console.log "display"
      domEl = $compile(angular.element(template))(scope)
      body = angular.element(document.body)
      body.append(domEl)

    open = () ->
      setup()
      prepareData()
      display()

    element.bind "click", ->
      console.log "click"
      scope.$apply ->
        open()

