# Pure Angular Datepicker, without jQuery

```js
angular.module('myApp', ['datepicker']);
// ...

$scope.dates = [start, end]
```


```html
<input type="text" datepicker ng-model="dates"/>
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

