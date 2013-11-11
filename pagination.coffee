class PaginationController
  constructor: (@$scope) ->

  init: (defaultItemsPerPage) ->
    @itemsPerPage = defaultItemsPerPage;
    @$scope.totalPages = @calculateTotalPages()

    @$scope.$watch 'currentPage', =>
      @render()

    @$scope.selectPage = @selectPage

  calculateTotalPages: ->
    totalPages = if @itemsPerPage < 1 then 1 else  Math.ceil(@$scope.totalItems / @itemsPerPage)
    Math.max(totalPages || 0, 1)

  render: ->
    @currentPage = parseInt(@$scope.currentPage, 10) || 1;
    if @currentPage > 0 && @currentPage <= @$scope.totalPages
      @$scope.pages = @getPages(@currentPage, @$scope.totalPages)

  isActive: (pageNumber) ->
    @currentPage is pageNumber

  makePage: (number, text, isActive, isDisabled) ->
    number: number
    text: text
    active: isActive
    disabled: isDisabled

  getPages: (currentPage, totalPages) ->
    pages = []
    startPage = 1
    endPage = totalPages

    # Add page number links
    for number in [startPage..endPage]
      pages.push(@makePage(number, number, @isActive(number), false))

    pages

  selectPage: (pageNumber) =>
    @$scope.currentPage = pageNumber


PaginationController.$inject = ['$scope']
angular.module('ui.foundation.pagination', [])
  
  .controller('PaginationController', PaginationController)
  
  .constant 'paginationConfig',
    itemsPerPage: 10
  
  .directive('pagination', ['$parse', 'paginationConfig', ($parse, defaultConfig) ->
    restrict: 'EA',
    scope:
      currentPage: '='
      totalItems: '='
      onSelectPage:' &'
    controller: 'PaginationController'
    templateUrl: 'pagination.html'
    replace: true
    link: (scope, element, attrs, paginationCtrl) ->

      paginationCtrl.init(defaultConfig.itemsPerPage)
      paginationCtrl.render()
  ])