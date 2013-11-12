angular.module('demoApp', ['ui.foundation.pagination'])

angular.module('demoApp')
  .controller('DemoCtrl', function($scope){
    $scope.angularLoaded = 'YES'  

    $scope.totalItems = 145
    $scope.currentPage = 3
    $scope.itemsPerPage = 10
  })
