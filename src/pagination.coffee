class PaginationController
  constructor: (@$scope, @$attrs, @$interpolate, @defaultConfig) ->

  init: (ctrlAttrs) ->
    @init_config(ctrlAttrs)
    @init_watchers()
    @init_scope_bindings()

  init_scope_bindings: ->
    @$scope.selectPage = @selectPage

  init_config: (ctrlAttrs)->
    @itemsPerPage   = @$scope.$parent.itemsPerPage    || @defaultConfig.itemsPerPage
    @$scope.itemsPerPage = @itemsPerPage

    @boundaryLinks  = @getAttributeValue( ctrlAttrs.boundaryLinks, @defaultConfig.boundaryLinks )      
    @directionLinks = @getAttributeValue( ctrlAttrs.directionLinks, @defaultConfig.directionLinks )
    @firstText      = @getAttributeValue( ctrlAttrs.firstText, @defaultConfig.firstText )
    @previousText   = @getAttributeValue( ctrlAttrs.previousText, @defaultConfig.previousText )
    @nextText       = @getAttributeValue( ctrlAttrs.nextText, @defaultConfig.nextText )
    @lastText       = @getAttributeValue( ctrlAttrs.lastText, @defaultConfig.lastText )
    @rotate         = @getAttributeValue( ctrlAttrs.rotate, @defaultConfig.rotate )
    @maxSize        = @getAttributeValue( ctrlAttrs.maxSize, @defaultConfig.maxSize )

  init_watchers: ->
    @$scope.$watch 'currentPage', =>
      @render()

    @$scope.$watch 'totalItems', =>
      @$scope.totalPages = @calculateTotalPages()

    @$scope.$watch 'totalPages', =>
      @render()

  getAttributeValue: (attribute, defaultValue, interpolate) ->
    if angular.isDefined(attribute)
      if interpolate 
        @$interpolate(attribute)(@$scope.$parent)
      else 
        @$scope.$parent.$eval(attribute)
    else
      defaultValue

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
    isMaxSized = @maxSize and @maxSize < totalPages
    
    # console.log(isMaxSized, @maxSize)

    # recompute if maxSized
    if isMaxSized
      if @rotate
        # Current page is displayed in the middle of the visible ones
        startPage = Math.max(currentPage - Math.floor(@maxSize/2), 1);
        endPage   = startPage + @maxSize - 1;

        # Adjust if limit is exceeded
        if (endPage > totalPages)
          endPage   = totalPages;
          startPage = endPage - @maxSize + 1;
      else
        # Visible pages are paginated with maxSize
        startPage = ((Math.ceil(currentPage / @maxSize) - 1) * @maxSize) + 1
        # Adjust last page if limit is exceeded
        endPage = Math.min(startPage + @maxSize - 1, totalPages)

    # Add page number links
    for number in [startPage..endPage]
      pages.push(@makePage(number, number, @isActive(number), false))

    # Add links to move between page sets
    if isMaxSized and not @rotate
      if startPage > 1
        previousPageSet = @makePage(startPage - 1, '...', false, false)
        pages.unshift(previousPageSet)

      if endPage < totalPages
        nextPageSet = @makePage(endPage + 1, '...', false, false)
        pages.push(nextPageSet)

    # Add direction links
    if @directionLinks
      previousPage = @makePage(currentPage - 1, @previousText, false, @noPrevious())
      pages.unshift(previousPage)
      nextPage = @makePage(currentPage + 1, @nextText, false, @noNext())
      pages.push(nextPage)

    # Add first & last links
    if @boundaryLinks
      firstPage = @makePage(1, @firstText, false, @noPrevious())
      pages.unshift(firstPage)

      lastPage = @makePage(totalPages, @lastText, false, @noNext())
      pages.push(lastPage)

    pages

  selectPage: (pageNumber) =>
    @$scope.currentPage = pageNumber

PaginationController.$inject = ['$scope', '$attrs', '$interpolate', 'paginationConfig']

angular.module('ui.foundation.pagination', [])
  
  .controller('PaginationController', PaginationController)
  
  .constant 'paginationConfig',
    itemsPerPage: 10
    boundaryLinks: false
    directionLinks: true
    firstText: 'First'
    previousText: 'Previous'
    nextText: 'Next'
    lastText: 'Last'
    rotate: true
    maxSize: 10
  
  .directive('pagination', [ ->
    restrict: 'EA',
    scope:
      currentPage: '='
      totalItems: '='
      onSelectPage:' &'
    controller: 'PaginationController'
    templateUrl: 'pagination.html'
    replace: true
    link: (scope, element, attrs, paginationCtrl) ->
      paginationCtrl.init(attrs)
      paginationCtrl.render()
  ])

  .run ($templateCache) ->
    $templateCache.put 'pagination.html', """
    <ul class="pagination">
      <li ng-repeat="page in pages" ng-class="{current: page.active, unavailable: page.disabled}">
        <a ng-click="selectPage(page.number)" ng-bind-html-unsafe="page.text"></a>
      </li>
    </ul>
    """