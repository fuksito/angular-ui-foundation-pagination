class PaginationController
  constructor: (@$scope, @$attrs) ->

  init: (defaultItemsPerPage) ->

    if @$scope.$parent.itemsPerPage
      @$scope.itemsPerPage = @$scope.$parent.itemsPerPage
    else
      @$scope.itemsPerPage = defaultItemsPerPage


    @$scope.selectPage = @selectPage

    @$scope.$watch 'currentPage', =>
      @render()

    @$scope.$watch 'totalItems', =>
      @$scope.totalPages = @calculateTotalPages()

    @$scope.$watch 'totalPages', =>
      @render()

  calculateTotalPages: ->
    totalPages = if @$scope.itemsPerPage < 1 then 1 else  Math.ceil(@$scope.totalItems / @$scope.itemsPerPage)
    Math.max(totalPages || 0, 1)

  render: ->
    @currentPage = parseInt(@$scope.currentPage, 10) || 1;
    if @currentPage > 0 && @currentPage <= @$scope.totalPages
      @$scope.pages = @getPages(@currentPage, @$scope.totalPages)

  noPrevious: ->
    @currentPage is 1

  noNext: ->
    @currentPage is @$scope.totalPages

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

    # Direction links
    previousText =  '&laquo;'
    nextText = "&raquo;"
    previousPage = @makePage(currentPage - 1, previousText, false, @noPrevious())
    pages.unshift(previousPage)
    nextPage = @makePage(currentPage + 1, nextText, false, @noNext())
    pages.push(nextPage)
    # /Direction links

    pages

  selectPage: (pageNumber) =>
    @$scope.currentPage = pageNumber


PaginationController.$inject = ['$scope', '$attrs', '$parse']
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

  .run ($templateCache) ->
    $templateCache.put 'pagination.html', """
    <ul class="pagination">
      <li ng-repeat="page in pages" ng-class="{current: page.active, unavailable: page.disabled}">
        <a ng-click="selectPage(page.number)" ng-bind="page.text"></a>
      </li>
    </ul>
    """