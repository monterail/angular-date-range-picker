(function() {
  angular.module("dateRangePicker", []);

  angular.module("dateRangePicker").directive("dateRangePicker", [
    "$compile", function($compile) {
      var oneDayRange, pickerTemplate;
      pickerTemplate = "<div ng-show=\"visible\" class=\"angular-date-range-picker__picker\">\n  <div class=\"angular-date-range-picker__timesheet\">\n    <button ng-click=\"move(-1, $event)\" class=\"angular-date-range-picker__prev-month\">&#9664;</button>\n    <div ng-repeat=\"month in months\" class=\"angular-date-range-picker__month\">\n      <div class=\"angular-date-range-picker__month-name\">{{ month.name }}</div>\n      <table class=\"angular-date-range-picker__calendar\">\n        <tr>\n          <th ng-repeat=\"day in month.weeks[1]\" class=\"angular-date-range-picker__calendar-weekday\">\n            {{ day.date.format(\"dd\") }}\n          </th>\n        </tr>\n        <tr ng-repeat=\"week in month.weeks\">\n          <td class=\"angular-date-range-picker__calendar-day\" ng-class='{\"angular-date-range-picker__calendar-day-selected\": day.selected, \"angular-date-range-picker__calendar-day-disabled\": day.disabled}' ng-repeat=\"day in week\" ng-click=\"select(day, $event)\">\n            {{ day.date.date() }}\n          </td>\n        </tr>\n      </table>\n    </div>\n    <button ng-click=\"move(+1, $event)\" class=\"angular-date-range-picker__next-month\">&#9654;</button>\n  </div>\n  <div class=\"angular-date-range-picker__panel\">\n    Select range: <select ng-model=\"quick\" ng-options=\"e.range as e.label for e in quickList\"></select>\n    <button ng-click=\"ok($event)\" class=\"angular-date-range-picker__apply\">Apply</button>\n    <a href=\"#\" ng-click=\"hide($event)\" class=\"angular-date-range-picker__cancel\">cancel</a>\n  </div>\n</div>";
      oneDayRange = moment().range("2013-01-01", "2013-01-02");
      return {
        restrict: "AE",
        replace: true,
        template: "<span class=\"angular-date-range-picker__input\">\n  <span ng-show=\"model\">{{ model.start.format(\"ll\") }} - {{ model.end.format(\"ll\") }}</span>\n  <span ng-hide=\"model\">Select date range</span>\n</span>",
        scope: {
          model: "=ngModel"
        },
        link: function($scope, element, attrs) {
          var domEl, _calculateRange, _prepare;
          $scope.quickList = [
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
          $scope.quick = null;
          $scope.range = null;
          $scope.selecting = false;
          $scope.visible = false;
          $scope.start = null;
          _calculateRange = function() {
            var end, start;
            return $scope.range = $scope.selection ? (start = $scope.selection.start.clone().startOf("month").startOf("day"), end = start.clone().add(2, "months").endOf("month").startOf("day"), moment().range(start, end)) : moment().range(moment().startOf("month").subtract(1, "month").startOf("day"), moment().endOf("month").add(1, "month").startOf("day"));
          };
          _prepare = function() {
            var m, startIndex, _i, _len, _ref, _results;
            $scope.months = [];
            startIndex = $scope.range.start.year() * 12 + $scope.range.start.month();
            $scope.range.by(oneDayRange, function(date) {
              var d, dis, m, sel, w, _base, _base1;
              m = date.year() * 12 + date.month() - startIndex;
              w = parseInt((7 + date.date() - date.day()) / 7);
              d = date.day();
              sel = false;
              dis = false;
              if ($scope.start) {
                sel = date === $scope.start;
                dis = date < $scope.start;
              } else {
                sel = $scope.selection && $scope.selection.contains(date);
              }
              (_base = $scope.months)[m] || (_base[m] = {
                name: date.format("MMMM YYYY"),
                weeks: []
              });
              (_base1 = $scope.months[m].weeks)[w] || (_base1[w] = []);
              return $scope.months[m].weeks[w][d] = {
                date: date,
                selected: sel,
                disabled: dis
              };
            });
            _ref = $scope.months;
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
          $scope.show = function() {
            $scope.selection = $scope.model;
            _calculateRange();
            _prepare();
            return $scope.visible = true;
          };
          $scope.hide = function($event) {
            if ($event != null) {
              if (typeof $event.stopPropagation === "function") {
                $event.stopPropagation();
              }
            }
            return $scope.visible = false;
          };
          $scope.ok = function($event) {
            if ($event != null) {
              if (typeof $event.stopPropagation === "function") {
                $event.stopPropagation();
              }
            }
            $scope.model = $scope.selection;
            return $scope.hide();
          };
          $scope.select = function(day, $event) {
            if ($event != null) {
              if (typeof $event.stopPropagation === "function") {
                $event.stopPropagation();
              }
            }
            if (day.disabled) {
              return;
            }
            $scope.selecting = !$scope.selecting;
            if ($scope.selecting) {
              $scope.start = day.date;
              return _prepare();
            } else {
              $scope.selection = moment().range($scope.start, day.date);
              $scope.start = null;
              return _prepare();
            }
          };
          $scope.move = function(n, $event) {
            if ($event != null) {
              if (typeof $event.stopPropagation === "function") {
                $event.stopPropagation();
              }
            }
            $scope.range = moment().range($scope.range.start.add(n, 'months').startOf("month").startOf("day"), $scope.range.start.clone().add(2, "months").endOf("month").startOf("day"));
            return _prepare();
          };
          $scope.$watch("quick", function(q, o) {
            if (!q) {
              return;
            }
            $scope.selection = $scope.quick;
            _calculateRange();
            return _prepare();
          });
          domEl = $compile(angular.element(pickerTemplate))($scope);
          element.append(domEl);
          element.bind("click", function(e) {
            if (e != null) {
              if (typeof e.stopPropagation === "function") {
                e.stopPropagation();
              }
            }
            return $scope.$apply(function() {
              if ($scope.visible) {
                return $scope.hide();
              } else {
                return $scope.show();
              }
            });
          });
          angular.element(document).bind("click", function(e) {
            return $scope.$apply(function() {
              return $scope.hide();
            });
          });
          _calculateRange();
          return _prepare();
        }
      };
    }
  ]);

}).call(this);
