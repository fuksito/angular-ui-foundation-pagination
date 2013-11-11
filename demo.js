angular.module('demoApp', ['ui.foundation.pagination'])

angular.module('demoApp')
  .controller('DemoCtrl', function($scope){
    $scope.angularLoaded = 'YES'  

    $scope.totalItems = 25;
    $scope.currentPage = 1;
    $scope.itemsPerPage = 3;
  })
