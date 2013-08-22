(function() {
  angular.module("datepicker", []);

  angular.module("datepicker").directive("datepicker", function($compile) {
    var template;
    template = "<div>\n  <a href=\"#\" ng-click=\"close()\">close</a>\n  <div ng-repeat=\"month in months\" class=\"month\">\n    {{ month.name }}\n    <table>\n      <tr ng-repeat=\"week in month.weeks\">\n        <td class=\"day\" ng-class=\"{selected: day.selected}\" ng-repeat=\"day in week\" ng-click=\"select(day)\">\n          {{ day.date.date() }}\n        </td>\n      </tr>\n    </table>\n  </div>\n  <select ng-model=\"quick\" ng-options=\"e.range as e.label for e in quickList\"></select>\n</div>";
    return {
      restrict: "A",
      replace: true,
      scope: {
        dates: "=ngModel"
      },
      link: function(scope, element, attrs, controller) {
        var display, domEl, oneDayRange, prepareData, range, setup;
        window.s = scope;
        console.log("dates", scope.dates);
        range = null;
        domEl = null;
        oneDayRange = moment().range(moment("2013-01-01"), moment("2013-01-02"));
        scope.quick = null;
        scope.quickList = [
          {
            label: "This week",
            range: moment().range(moment().startOf("week"), moment().endOf("week"))
          }, {
            label: "Next week",
            range: moment().range(moment().startOf("week").add(1, "week"), moment().endOf("week").add(1, "week"))
          }, {
            label: "This month",
            range: moment().range(moment().startOf("month"), moment().endOf("month"))
          }, {
            label: "Next month",
            range: moment().range(moment().startOf("month").add(1, "month"), moment().endOf("month").add(1, "month"))
          }
        ];
        setup = function() {
          var end, start;
          start = scope.selection.start.clone().startOf("month").startOf("day");
          end = start.clone().add(2, "months").endOf("month").startOf("day");
          return range = moment().range(start, end);
        };
        prepareData = function() {
          var m, startIndex, _i, _len, _ref, _results;
          scope.months = [];
          startIndex = range.start.year() * 12 + range.start.month();
          range.by(oneDayRange, function(date) {
            var d, m, s, w, _base, _base1;
            m = date.year() * 12 + date.month() - startIndex;
            w = parseInt((7 + date.date() - date.day()) / 7);
            d = date.day();
            s = scope.selection.contains(date);
            (_base = scope.months)[m] || (_base[m] = {
              name: date.format("MMMM YYYY"),
              weeks: []
            });
            (_base1 = scope.months[m].weeks)[w] || (_base1[w] = []);
            return scope.months[m].weeks[w][d] = {
              date: date,
              selected: s
            };
          });
          _ref = scope.months;
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
        scope.opened = false;
        scope.select = function(day) {
          scope.selecting = !scope.selecting;
          if (scope.selecting) {
            scope.selection = moment().range(day.date, day.date);
          } else {
            scope.selection = moment().range(scope.selection.start, day.date);
            scope.dates = [scope.selection.start.toDate(), day.date.toDate()];
          }
          return prepareData();
        };
        scope.close = function() {
          domEl.remove();
          return scope.opened = false;
        };
        scope.$watch("dates", function() {
          scope.selection = moment().range(scope.dates[0], scope.dates[1]);
          setup();
          return prepareData();
        });
        scope.$watch("quick", function(q, o) {
          if (!q) {
            return;
          }
          console.log("quick", scope.quick);
          scope.selection = scope.quick;
          setup();
          return prepareData();
        });
        display = function() {
          var body;
          console.log("display");
          domEl = $compile(angular.element(template))(scope);
          body = angular.element(document.body);
          return body.append(domEl);
        };
        scope.open = function() {
          scope.selection = moment().range(scope.dates[0], scope.dates[1]);
          setup();
          prepareData();
          display();
          return scope.opened = true;
        };
        return element.bind("click", function() {
          console.log("click");
          return scope.$apply(function() {
            if (scope.opened) {
              return scope.close();
            } else {
              return scope.open();
            }
          });
        });
      }
    };
  });

}).call(this);
