angular.module('demoApp', ['ui.foundation.pagination'])

angular.module('demoApp')
  .controller('DemoCtrl', function($scope){
    $scope.angularLoadedText = 'AngularJS'
    
    $scope.itemsPerPage = 10
    $scope.totalItems = 47 // 5 pages
    $scope.currentPage = 3

    $scope.bigTotalItems = 167 // 5 pages
    $scope.maxSize = 5

  })
