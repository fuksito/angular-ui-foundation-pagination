angular.module('demoApp', ['ui.foundation.pagination'])

angular.module('demoApp')
  .controller('DemoCtrl', function($scope){
    $scope.angularLoaded = 'YES'  

    $scope.totalItems = 43;
    $scope.currentPage = 2;
  })
