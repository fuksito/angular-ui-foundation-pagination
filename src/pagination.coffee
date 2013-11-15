class PaginationController
  constructor: (@$scope, @$attrs, @$interpolate, @$parse, @defaultConfig) ->

  init: (ctrlAttrs) ->
    @init_config(ctrlAttrs)
    @init_watchers(ctrlAttrs)
    @init_scope_bindings()
    @setNumPages = if ctrlAttrs.numPages then @$parse(ctrlAttrs.numPages).assign else angular.noop

  init_scope_bindings: ->
    @$scope.selectPage = @selectPage

  init_config: (ctrlAttrs) ->
    if ctrlAttrs.itemsPerPage
      @itemsPerPage = @getAttributeValue( ctrlAttrs.itemsPerPage, @defaultConfig.itemsPerPage )
    else
      @itemsPerPage = @defaultConfig.itemsPerPage

    @boundaryLinks  = @getAttributeValue( ctrlAttrs.boundaryLinks, @defaultConfig.boundaryLinks )      
    @directionLinks = @getAttributeValue( ctrlAttrs.directionLinks, @defaultConfig.directionLinks )
    @firstText      = @getAttributeValue( ctrlAttrs.firstText, @defaultConfig.firstText, true )
    @previousText   = @getAttributeValue( ctrlAttrs.previousText, @defaultConfig.previousText, true )
    @nextText       = @getAttributeValue( ctrlAttrs.nextText, @defaultConfig.nextText, true )
    @lastText       = @getAttributeValue( ctrlAttrs.lastText, @defaultConfig.lastText, true )
    @rotate         = @getAttributeValue( ctrlAttrs.rotate, @defaultConfig.rotate )
    @maxSize        = @getAttributeValue( ctrlAttrs.maxSize, null )
    @currentPage    = @getAttributeValue( ctrlAttrs.currentPage, 1 )

  init_watchers: (ctrlAttrs) ->
    @$scope.$watch 'currentPage', =>
      @render()

    @$scope.$watch 'totalItems', =>
      @$scope.totalPages = @calculateTotalPages()

    @$scope.$watch 'totalPages', (value) =>
      # Readonly variable
      @setNumPages(@$scope.$parent, value); 

      # selects the last page when current page is too big
      if @$scope.currentPage > @$scope.totalPages
        @$scope.currentPage = @$scope.totalPages
      @render()

    if ctrlAttrs.itemsPerPage
      @$scope.$parent.$watch @$parse(ctrlAttrs.itemsPerPage), (value) =>
        @itemsPerPage = parseInt(value, 10)
        @$scope.totalPages = @calculateTotalPages()

    if ctrlAttrs.maxSize
      @$scope.$parent.$watch @$parse(ctrlAttrs.maxSize), (value) =>
        @maxSize = parseInt(value, 10)
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
    totalPages = if @itemsPerPage < 1 then 1 else  Math.ceil(@$scope.totalItems / @itemsPerPage)
    Math.max(totalPages || 0, 1)

  render: ->
    @current_page = parseInt(@$scope.currentPage, 10) || 1;
    @$scope.totalPages = parseInt(@$scope.totalPages, 10) || 1
    if @current_page > 0
      @$scope.pages = @getPages(@current_page, @$scope.totalPages)

  noPrevious: ->
    @current_page is 1

  noNext: ->
    @current_page is @$scope.totalPages

  isActive: (pageNumber) ->
    @current_page is pageNumber

  makePage: (number, text, isActive, isDisabled) ->
    number: number
    text: text
    active: isActive
    disabled: isDisabled

  getPages: (currentPage, totalPages) ->
    pages = []
    startPage = 1
    endPage = totalPages
    
    isMaxSized = (@maxSize != null && @maxSize < totalPages)
    # console.log( ' ' + @maxSize + ' ' + isMaxSized )
    # recompute if maxSized
    if isMaxSized
      if @rotate
        # Current page is displayed in the middle of the visible ones
        startPage = Math.max(currentPage - Math.floor(@maxSize/2), 1);
        endPage   = startPage + @maxSize - 1;

        # Adjust if limit is exceeded
        if (endPage > totalPages)
          endPage   = totalPages;
          startPage = endPage - @maxSize + 1

      else
        # Visible pages are paginated with maxSize
        startPage = ((Math.ceil(currentPage / @maxSize) - 1) * @maxSize) + 1
        # Adjust last page if limit is exceeded
        endPage = Math.min(startPage + @maxSize - 1, totalPages)

    # Add page number links
    if startPage <= endPage # todo: don't like this check. the [3..2] should result in [] and not in array. mb rewrite to loop
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
    if @isActive and pageNumber > 0 and pageNumber <= @$scope.totalPages
      @$scope.currentPage = pageNumber
      @$scope.onSelectPage({ page: pageNumber })

PaginationController.$inject = ['$scope', '$attrs', '$interpolate', '$parse', 'paginationConfig']

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

  .run(['$templateCache', ($templateCache) ->
    $templateCache.put 'pagination.html', """
    <ul class="pagination">
      <li ng-repeat="page in pages" ng-class="{current: page.active, unavailable: page.disabled}">
        <a ng-click="selectPage(page.number)">{{page.text}}</a>
      </li>
    </ul>
    """
  ])