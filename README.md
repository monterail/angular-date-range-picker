# Pure Angular Datepicker, without jQuery

## Install

```
bower install angular-date-range-picker
```


## Usage

```js
// require dateRangePicker module as dependency
angular.module('myApp', ['dateRangePicker']);
```

```js
// specify default date range in controller
$scope.dates = moment().range("2012-11-05", "2013-01-25")
```

```html
<!-- use 'date-range-picker' directive in view -->
<input type="text" date-range-picker ng-model="dates"/>
```

## Angular version compatibility table

Due to usage of `track by $index` it is impossible to provide one version for both angular `< 1.2` and `>= 1.2`.

<table>
  <tr>
    <th>Angular version</th>
    <th>date-range-picker version</th>
  </tr>
  <tr>
    <td>1.2.x</td><td>0.3.x</td>
  </tr>
  <tr>
    <td>1.1.x</td><td>0.2.x</td>
  </tr>
  <tr>
    <td>1.0.x</td><td>0.2.x</td>
  </tr>
</table>




## Development

```bash
npm install
bower install
grunt watch
open test/index.html
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

