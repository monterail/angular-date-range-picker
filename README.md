# Pure Angular Datepicker, without jQuery

## Install

```
bower install angular-date-range-picker
```

```js
angular.module('myApp', ['dateRangePicker']);
// ...

$scope.dates = moment().range("2012-11-05", "2013-01-25")
```


```html
<input type="text" date-range-picker ng-model="dates"/>
```



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

