(function() {
  angular.module("datepicker", []);

  angular.module("datepicker").directive("datepicker", function($compile) {
    var template;
    template = "<div>\n  <a href=\"#\" ng-click=\"close()\">close</a>\n  <div ng-repeat=\"month in _picker.months\" class=\"month\">\n    {{ month.name }}\n    <table>\n      <tr ng-repeat=\"week in month.weeks\">\n        <td class=\"day\" ng-class=\"{selected: day.selected}\" ng-repeat=\"day in week\" ng-click=\"select(day)\">\n          {{ day.date.date() }}\n        </td>\n      </tr>\n    </table>\n  </div>\n</div>";
    return {
      restrict: "A",
      replace: true,
      scope: {
        dates: "=ngModel"
      },
      link: function(scope, element, attrs, controller) {
        var display, domEl, oneDayRange, open, prepareData, range, selection, setup;
        window.s = scope;
        console.log("dates", scope.dates);
        selection = null;
        range = null;
        domEl = null;
        oneDayRange = moment().range(moment("2013-01-01"), moment("2013-01-02"));
        scope._picker = {};
        setup = function() {
          var end;
          selection = moment().range(scope.dates[0], scope.dates[1]);
          end = moment(scope.dates[1]).endOf("month");
          return range = moment().range(end.clone().subtract(3, "months").add(1, "day"), end);
        };
        prepareData = function() {
          var m, startMonth, _i, _len, _ref, _results;
          startMonth = range.start.month();
          scope._picker.months = [];
          range.by(oneDayRange, function(date) {
            var d, m, s, w, _base, _base1;
            m = date.month() - startMonth;
            w = parseInt((7 + date.date() - date.day()) / 7);
            d = date.day();
            s = selection.contains(date);
            (_base = scope._picker.months)[m] || (_base[m] = {
              name: date.format("MMMM YYYY"),
              weeks: []
            });
            (_base1 = scope._picker.months[m].weeks)[w] || (_base1[w] = []);
            return scope._picker.months[m].weeks[w][d] = {
              date: date,
              selected: s
            };
          });
          _ref = scope._picker.months;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            m = _ref[_i];
            if (!m.weeks[0]) {
              _results.push(m.weeks.splice(0, 1));
            } else {
              _results.push(void 0);
            }
          }
          return _results;
        };
        scope.selecting = false;
        scope.select = function(day) {
          scope.selecting = !scope.selecting;
          if (scope.selecting) {
            selection = moment().range(day.date, day.date);
          } else {
            selection = moment().range(selection.start, day.date);
            scope.dates = [selection.start.toDate(), day.date.toDate()];
          }
          return prepareData();
        };
        scope.close = function() {
          return domEl.remove();
        };
        display = function() {
          var body;
          console.log("display");
          domEl = $compile(angular.element(template))(scope);
          body = angular.element(document.body);
          return body.append(domEl);
        };
        open = function() {
          setup();
          prepareData();
          return display();
        };
        return element.bind("click", function() {
          console.log("click");
          return scope.$apply(function() {
            return open();
          });
        });
      }
    };
  });

}).call(this);
