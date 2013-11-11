// Generated by CoffeeScript 1.6.3
(function() {
  var PaginationController,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  PaginationController = (function() {
    function PaginationController($scope) {
      this.$scope = $scope;
      this.selectPage = __bind(this.selectPage, this);
    }

    PaginationController.prototype.init = function(defaultItemsPerPage) {
      var _this = this;
      this.itemsPerPage = defaultItemsPerPage;
      this.$scope.totalPages = this.calculateTotalPages();
      this.$scope.$watch('currentPage', function() {
        return _this.render();
      });
      return this.$scope.selectPage = this.selectPage;
    };

    PaginationController.prototype.calculateTotalPages = function() {
      var totalPages;
      totalPages = this.itemsPerPage < 1 ? 1 : Math.ceil(this.$scope.totalItems / this.itemsPerPage);
      return Math.max(totalPages || 0, 1);
    };

    PaginationController.prototype.render = function() {
      this.currentPage = parseInt(this.$scope.currentPage, 10) || 1;
      if (this.currentPage > 0 && this.currentPage <= this.$scope.totalPages) {
        return this.$scope.pages = this.getPages(this.currentPage, this.$scope.totalPages);
      }
    };

    PaginationController.prototype.isActive = function(pageNumber) {
      return this.currentPage === pageNumber;
    };

    PaginationController.prototype.makePage = function(number, text, isActive, isDisabled) {
      return {
        number: number,
        text: text,
        active: isActive,
        disabled: isDisabled
      };
    };

    PaginationController.prototype.getPages = function(currentPage, totalPages) {
      var endPage, number, pages, startPage, _i;
      pages = [];
      startPage = 1;
      endPage = totalPages;
      for (number = _i = startPage; startPage <= endPage ? _i <= endPage : _i >= endPage; number = startPage <= endPage ? ++_i : --_i) {
        pages.push(this.makePage(number, number, this.isActive(number), false));
      }
      return pages;
    };

    PaginationController.prototype.selectPage = function(pageNumber) {
      return this.$scope.currentPage = pageNumber;
    };

    return PaginationController;

  })();

  PaginationController.$inject = ['$scope'];

  angular.module('ui.foundation.pagination', []).controller('PaginationController', PaginationController).constant('paginationConfig', {
    itemsPerPage: 10
  }).directive('pagination', [
    '$parse', 'paginationConfig', function($parse, defaultConfig) {
      return {
        restrict: 'EA',
        scope: {
          currentPage: '=',
          totalItems: '=',
          onSelectPage: ' &'
        },
        controller: 'PaginationController',
        templateUrl: 'pagination.html',
        replace: true,
        link: function(scope, element, attrs, paginationCtrl) {
          paginationCtrl.init(defaultConfig.itemsPerPage);
          return paginationCtrl.render();
        }
      };
    }
  ]).run(function($templateCache) {
    return $templateCache.put('pagination.html', "<ul class=\"pagination\">\n  <li ng-repeat=\"page in pages\" ng-class=\"{current: page.active, unavailable: page.disabled}\">\n    <a ng-click=\"selectPage(page.number)\">{{page.text}}</a>\n  </li>\n</ul>");
  });

}).call(this);
