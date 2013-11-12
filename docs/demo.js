angular.module('demoApp', ['ui.foundation.pagination'])

angular.module('demoApp')
  .controller('DemoCtrl', function($scope){
    $scope.angularLoadedText = 'AngularJS'
  })
  .controller('defaultCtrl', function($scope){
    $scope.itemsPerPage = 10
    $scope.totalItems = 47 // 5 pages
    $scope.currentPage = 3
  })
  .controller('limitCtrl', function($scope){
    $scope.itemsPerPage = 10
    $scope.totalItems = 167 // 5 pages
    $scope.currentPage = 3
    $scope.maxSize = 5
  })
