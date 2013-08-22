(function() {
  angular.module("datepicker", []);

  angular.module("datepicker").directive("dateRangePicker", function($compile) {
    var oneDayRange, pickerTemplate;
    pickerTemplate = "<div ng-show=\"visible\" class=\"angular-datepicker_picker\">\n  <button ng-click=\"move(-1, $event)\" class=\"angular-datepicker_picker_prev-month\"><</button>\n  <div ng-repeat=\"month in months\" class=\"angular-datepicker_picker_month\">\n    <div class=\"angular-datepicker_picker_month_name\">{{ month.name }}</div>\n    <table class=\"angular-datepicker_picker_calendar\">\n      <tr>\n        <th ng-repeat=\"day in month.weeks[1]\" class=\"angular-datepicker_picker_calendar_weekday\">\n          {{ day.date.format(\"dd\") }}\n        </th>\n      </tr>\n      <tr ng-repeat=\"week in month.weeks\">\n        <td class=\"angular-datepicker_picker_calendar_day\" ng-class='{\"angular-datepicker_picker_calendar_day_selected\": day.selected, \"angular-datepicker_picker_calendar_day_disabled\": day.disabled}' ng-repeat=\"day in week\" ng-click=\"select(day, $event)\">\n          {{ day.date.date() }}\n        </td>\n      </tr>\n    </table>\n  </div>\n  <button ng-click=\"move(+1, $event)\" class=\"angular-datepicker_picker_next-month\">></button>\n  <div class=\" class=\"angular-datepicker_picker_panel\">\n    Select range: <select ng-model=\"quick\" ng-options=\"e.range as e.label for e in quickList\"></select>\n    <a href=\"#\" ng-click=\"hide()\" class=\"angular-datepicker_picker_close\">close</a>\n  </div>\n</div>";
    oneDayRange = moment().range("2013-01-01", "2013-01-02");
    return {
      restrict: "AE",
      replace: true,
      template: "<span class=\"angular-datepicker_input\">\n  {{ selection.start.format(\"ll\") }} - {{ selection.end.format(\"ll\") }}\n</span>",
      scope: {
        selection: "=ngModel"
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
        $scope.selectiong = false;
        $scope.visible = false;
        $scope.start = null;
        _calculateRange = function() {
          var end, start;
          start = $scope.selection.start.clone().startOf("month").startOf("day");
          end = start.clone().add(2, "months").endOf("month").startOf("day");
          $scope.range = moment().range(start, end);
          return console.log("$scope.range", $scope.range.start.toDate(), $scope.range.end.toDate());
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
              sel = $scope.selection.contains(date);
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
          return $scope.visible = true;
        };
        $scope.hide = function() {
          return $scope.visible = false;
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
            return $scope.start = null;
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
        $scope.$watch("selection", function(s, o) {
          if (!s || s === o) {
            return;
          }
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
  });

}).call(this);
