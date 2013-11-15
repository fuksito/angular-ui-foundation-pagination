describe 'pagination directive', ->

  $compile = null
  $rootScope = null
  element = null

  beforeEach(module('ui.foundation.pagination'))
  
  beforeEach(inject( ( _$compile_ , _$rootScope_ ) ->
    $compile = _$compile_
    $rootScope = _$rootScope_

    $rootScope.itemsPerPage = 10
    $rootScope.totalItems = 47 # 5 pages
    $rootScope.currentPage = 3
    
    element = $compile('<div><pagination total-items="totalItems" current-page="currentPage"></pagination></div>')($rootScope)
    $rootScope.$digest()
  ))

  getPaginationBarSize = ->
    element.find('li').length

  getPaginationEl = (index) ->
    element.find('li').eq(index)
  
  getPaginationElText = (index) ->
    getPaginationEl(index).find('a').text()

  clickPaginationEl = (index) ->
    getPaginationEl(index).find('a').click()

  updateCurrentPage = (value) ->
    $rootScope.currentPage = value
    $rootScope.$digest()

  it 'has a "pagination" css class on ul', ->
    expect(element.find('ul').hasClass('pagination')).toBe(true)

  it 'contains one ul and num-pages li elements', ->
    expect(element.find('ul').length).toBe(1)
    expect(element.find('li').length).toBe(7)
    expect(getPaginationEl(0).find('a').text()).toBe('Previous')
    expect(getPaginationEl(-1).find('a').text()).toBe('Next')

  it 'has the number of the page as text in each page item', ->
    for i in [1..5]
      expect(getPaginationElText(i)).toEqual(''+i)

  it 'sets the current page to be current', ->
    expect(getPaginationEl($rootScope.currentPage).hasClass('current')).toBe(true)

  it 'disables the "previous" link if current page is 1', ->
    updateCurrentPage(1)
    expect(getPaginationEl(0).hasClass('unavailable')).toBe(true)

   it 'disables the "next" link if current page is last', ->
    updateCurrentPage 5
    expect(getPaginationEl(-1).hasClass("unavailable")).toBe true

  it 'changes currentPage if a page link is clicked', ->
    clickPaginationEl 2
    expect($rootScope.currentPage).toBe 2

  it 'changes currentPage if the "previous" link is clicked', ->
    clickPaginationEl 0
    expect($rootScope.currentPage).toBe 2

  it 'changes currentPage if the "next" link is clicked', ->
    clickPaginationEl -1
    expect($rootScope.currentPage).toBe 4

  it "does not change the current page on \"previous\" click if already at first page", ->
    updateCurrentPage 1
    clickPaginationEl 0
    expect($rootScope.currentPage).toBe 1

  it "does not change the current page on \"next\" click if already at last page", ->
    updateCurrentPage 5
    clickPaginationEl -1
    expect($rootScope.currentPage).toBe 5

  it "changes the number of pages when `total-items` changes", ->
    $rootScope.totalItems = 78 # 8 pages
    $rootScope.$digest()
    expect(getPaginationBarSize()).toBe 10
    expect(getPaginationElText(0)).toBe "Previous"
    expect(getPaginationElText(-1)).toBe "Next"

  it "does not \"break\" when `total-items` is undefined", ->
    $rootScope.totalItems = `undefined`
    $rootScope.$digest()
    expect(getPaginationBarSize()).toBe 3 # Previous, 1, Next
    expect(getPaginationEl(0)).toHaveClass "unavailable"
    expect(getPaginationEl(1)).toHaveClass "current"
    expect(getPaginationEl(2)).toHaveClass "unavailable"

  it "does not \"break\" when `total-items` is negative", ->
    $rootScope.totalItems = -1
    $rootScope.$digest()
    expect(getPaginationBarSize()).toBe 3 # Previous, 1, Next
    expect(getPaginationEl(0)).toHaveClass "unavailable"
    expect(getPaginationEl(1)).toHaveClass "current"
    expect(getPaginationEl(2)).toHaveClass "unavailable"

  it "does not change the current page when `total-items` changes but is valid", ->
    $rootScope.currentPage = 1
    $rootScope.totalItems = 18 # 2 pages
    $rootScope.$digest()
    expect($rootScope.currentPage).toBe 1

  describe '`items-per-page`', ->
      beforeEach(inject( ->
        $rootScope.perpage = 5
        element = $compile('<pagination total-items="totalItems" items-per-page="perpage" current-page="currentPage" on-select-page="selectPageHandler(page)"></pagination>')($rootScope)
        $rootScope.$digest()
      ))

      it 'changes the number of pages', ->
        expect(getPaginationBarSize()).toBe(12)
        expect(getPaginationElText(0)).toBe('Previous')
        expect(getPaginationElText(-1)).toBe('Next')

      it 'changes the number of pages when changes', ->
        $rootScope.perpage = 20
        $rootScope.$digest()

        expect(getPaginationBarSize()).toBe(5)
        expect(getPaginationElText(0)).toBe('Previous')
        expect(getPaginationElText(-1)).toBe('Next')

      it 'selects the last page when current page is too big', ->
        $rootScope.perpage = 30
        $rootScope.$digest()

        expect($rootScope.currentPage).toBe(2)
        expect(getPaginationBarSize()).toBe(4)
        expect(getPaginationElText(0)).toBe('Previous')
        expect(getPaginationElText(-1)).toBe('Next')

      it 'displays a single page when it is negative', ->
        $rootScope.perpage = -1
        $rootScope.$digest()

        expect(getPaginationBarSize()).toBe(3)
        expect(getPaginationElText(0)).toBe('Previous')
        expect(getPaginationElText(1)).toBe('1')
        expect(getPaginationElText(-1)).toBe('Next')

  describe 'executes `on-select-page` expression', ->
    beforeEach(inject( ->
      $rootScope.selectPageHandler = jasmine.createSpy('selectPageHandler')
      element = $compile('<pagination total-items="totalItems" current-page="currentPage" on-select-page="selectPageHandler(page)"></pagination>')($rootScope)
      $rootScope.$digest()
    ))

    it 'when an element is clicked', ->
      clickPaginationEl(2)
      expect($rootScope.selectPageHandler).toHaveBeenCalledWith(2)

  describe 'when `page` is not a number', ->
    it 'handles string', ->
      updateCurrentPage('2');
      expect(getPaginationEl(2)).toHaveClass('current')
      updateCurrentPage('04');
      expect(getPaginationEl(4)).toHaveClass('current')


  describe "with `max-size` option", ->
    beforeEach inject(->
      $rootScope.total = 98 # 10 pages
      $rootScope.currentPage = 3
      $rootScope.maxSize = 5
      element = $compile("<pagination total-items=\"total\" current-page=\"currentPage\" max-size=\"maxSize\"></pagination>")($rootScope)
      $rootScope.$digest()
    )
    it "contains maxsize + 2 li elements", ->
      expect(getPaginationBarSize()).toBe $rootScope.maxSize + 2
      expect(getPaginationEl(0).text().trim()).toBe "Previous"
      expect(getPaginationEl(-1).text().trim().trim()).toBe "Next"

    it "shows the page number even if it can't be shown in the middle", ->
      updateCurrentPage 1
      expect(getPaginationEl(1)).toHaveClass "current"
      updateCurrentPage 10
      expect(getPaginationEl(-2)).toHaveClass "current"

    it "shows the page number in middle after the next link is clicked", ->
      updateCurrentPage 6
      clickPaginationEl -1
      expect($rootScope.currentPage).toBe 7
      expect(getPaginationEl(3)).toHaveClass "current"
      expect(getPaginationEl(3).text().trim()).toBe "" + $rootScope.currentPage

    it "shows the page number in middle after the prev link is clicked", ->
      updateCurrentPage 7
      clickPaginationEl 0
      expect($rootScope.currentPage).toBe 6
      expect(getPaginationEl(3)).toHaveClass "current"
      expect(getPaginationEl(3).text().trim()).toBe "" + $rootScope.currentPage

    it "changes pagination bar size when max-size value changed", ->
      $rootScope.maxSize = 7
      $rootScope.$digest()
      expect(getPaginationBarSize()).toBe 9

    it "sets the pagination bar size to num-pages, if max-size is greater than num-pages ", ->
      $rootScope.maxSize = 15
      $rootScope.$digest()
      expect(getPaginationBarSize()).toBe 12

    it "should not change value of max-size expression, if max-size is greater than num-pages ", ->
      $rootScope.maxSize = 15
      $rootScope.$digest()
      expect($rootScope.maxSize).toBe 15

    it "should not display page numbers, if max-size is zero", ->
      $rootScope.maxSize = 0
      $rootScope.$digest()
      expect(getPaginationBarSize()).toBe 2
      expect(getPaginationEl(0).text().trim()).toBe "Previous"
      expect(getPaginationEl(-1).text().trim()).toBe "Next"


  describe "with `max-size` option & no `rotate`", ->
    beforeEach inject(->
      $rootScope.total = 115 # 12 pages
      $rootScope.currentPage = 7
      $rootScope.maxSize = 5
      $rootScope.rotate = false
      element = $compile("<pagination total-items=\"total\" current-page=\"currentPage\" max-size=\"maxSize\" rotate=\"rotate\"></pagination>")($rootScope)
      $rootScope.$digest()
    )
    it "contains one ul and maxsize + 4 elements", ->
      expect(element.find("ul").length).toBe 1
      expect(getPaginationBarSize()).toBe $rootScope.maxSize + 4
      expect(getPaginationEl(0).text().trim()).toBe "Previous"
      expect(getPaginationEl(1).text().trim()).toBe "..."
      expect(getPaginationEl(2).text().trim()).toBe "6"
      expect(getPaginationEl(-3).text().trim()).toBe "10"
      expect(getPaginationEl(-2).text().trim()).toBe "..."
      expect(getPaginationEl(-1).text().trim()).toBe "Next"

    it "shows only the next ellipsis element on first page set", ->
      updateCurrentPage 3
      expect(getPaginationEl(1).text().trim()).toBe "1"
      expect(getPaginationEl(-3).text().trim()).toBe "5"
      expect(getPaginationEl(-2).text().trim()).toBe "..."

    it "shows only the previous ellipsis element on last page set", ->
      updateCurrentPage 12
      expect(getPaginationBarSize()).toBe 5
      expect(getPaginationEl(1).text().trim()).toBe "..."
      expect(getPaginationEl(2).text().trim()).toBe "11"
      expect(getPaginationEl(-2).text().trim()).toBe "12"

    it "moves to the previous set when first ellipsis is clicked", ->
      expect(getPaginationEl(1).text().trim()).toBe "..."
      clickPaginationEl 1
      expect($rootScope.currentPage).toBe 5
      expect(getPaginationEl(-3)).toHaveClass "current"

    it "moves to the next set when last ellipsis is clicked", ->
      expect(getPaginationEl(-2).text().trim()).toBe "..."
      clickPaginationEl -2
      expect($rootScope.currentPage).toBe 11
      expect(getPaginationEl(2)).toHaveClass "current"

    it "should not display page numbers, if max-size is zero", ->
      $rootScope.maxSize = 0
      $rootScope.$digest()
      expect(getPaginationBarSize()).toBe 2
      expect(getPaginationEl(0).text().trim()).toBe "Previous"
      expect(getPaginationEl(1).text().trim()).toBe "Next"


  describe "pagination directive with `boundary-links`", ->
    beforeEach inject(->
      element = $compile("<pagination boundary-links=\"true\" total-items=\"total\" current-page=\"currentPage\"></pagination>")($rootScope)
      $rootScope.$digest()
    )
    it "contains one ul and num-pages + 4 li elements", ->
      expect(element.find("ul").length).toBe 1
      expect(getPaginationBarSize()).toBe 9
      expect(getPaginationEl(0).text().trim()).toBe "First"
      expect(getPaginationEl(1).text().trim()).toBe "Previous"
      expect(getPaginationEl(-2).text().trim()).toBe "Next"
      expect(getPaginationEl(-1).text().trim()).toBe "Last"

    it "has first and last li elements visible", ->
      expect(getPaginationEl(0).css("display")).not.toBe "none"
      expect(getPaginationEl(-1).css("display")).not.toBe "none"

    it "disables the \"first\" & \"previous\" link if current page is 1", ->
      updateCurrentPage 1
      expect(getPaginationEl(0)).toHaveClass "unavailable"
      expect(getPaginationEl(1)).toHaveClass "unavailable"

    it "disables the \"last\" & \"next\" link if current page is num-pages", ->
      updateCurrentPage 5
      expect(getPaginationEl(-2)).toHaveClass "unavailable"
      expect(getPaginationEl(-1)).toHaveClass "unavailable"

    it "changes currentPage if the \"first\" link is clicked", ->
      clickPaginationEl 0
      expect($rootScope.currentPage).toBe 1

    it "changes currentPage if the \"last\" link is clicked", ->
      clickPaginationEl -1
      expect($rootScope.currentPage).toBe 5

    it "does not change the current page on \"first\" click if already at first page", ->
      updateCurrentPage 1
      clickPaginationEl 0
      expect($rootScope.currentPage).toBe 1

    it "does not change the current page on \"last\" click if already at last page", ->
      updateCurrentPage 5
      clickPaginationEl -1
      expect($rootScope.currentPage).toBe 5

    it "changes \"first\" & \"last\" text from attributes", ->
      element = $compile("<pagination boundary-links=\"true\" first-text=\"<<<\" last-text=\">>>\" total-items=\"total\" current-page=\"currentPage\"></pagination>")($rootScope)
      $rootScope.$digest()
      expect(getPaginationEl(0).text().trim()).toBe "<<<"
      expect(getPaginationEl(-1).text().trim()).toBe ">>>"

    it "changes \"previous\" & \"next\" text from attributes", ->
      element = $compile("<pagination boundary-links=\"true\" previous-text=\"<<\" next-text=\">>\" total-items=\"total\" current-page=\"currentPage\"></pagination>")($rootScope)
      $rootScope.$digest()
      expect(getPaginationEl(1).text().trim()).toBe "<<"
      expect(getPaginationEl(-2).text().trim()).toBe ">>"

    it "changes \"first\" & \"last\" text from interpolated attributes", ->
      $rootScope.myfirstText = "<<<"
      $rootScope.mylastText = ">>>"
      element = $compile("<pagination boundary-links=\"true\" first-text=\"{{myfirstText}}\" last-text=\"{{mylastText}}\" total-items=\"total\" current-page=\"currentPage\"></pagination>")($rootScope)
      $rootScope.$digest()
      expect(getPaginationEl(0).text().trim()).toBe "<<<"
      expect(getPaginationEl(-1).text().trim()).toBe ">>>"

    it "changes \"previous\" & \"next\" text from interpolated attributes", ->
      $rootScope.previousText = "<<"
      $rootScope.nextText = ">>"
      element = $compile("<pagination boundary-links=\"true\" previous-text=\"{{previousText}}\" next-text=\"{{nextText}}\" total-items=\"total\" current-page=\"currentPage\"></pagination>")($rootScope)
      $rootScope.$digest()
      expect(getPaginationEl(1).text().trim()).toBe "<<"
      expect(getPaginationEl(-2).text().trim()).toBe ">>"


  describe "pagination directive with just number links", ->
    beforeEach inject(->
      element = $compile("<pagination direction-links=\"false\" total-items=\"total\" current-page=\"currentPage\"></pagination>")($rootScope)
      $rootScope.$digest()
    )
    it "contains one ul and num-pages li elements", ->
      expect(getPaginationBarSize()).toBe 5
      expect(getPaginationEl(0).text().trim()).toBe "1"
      expect(getPaginationEl(-1).text().trim()).toBe "5"

    it "has the number of the page as text in each page item", ->
      i = 0

      while i < 5
        expect(getPaginationEl(i).text().trim()).toEqual "" + (i + 1)
        i++

    it "sets the current page to be current", ->
      expect(getPaginationEl(2)).toHaveClass "current"

    it "does not disable the \"1\" link if current page is 1", ->
      updateCurrentPage 1
      expect(getPaginationEl(0)).not.toHaveClass "unavailable"
      expect(getPaginationEl(0)).toHaveClass "current"

    it "does not disable the \"last\" link if current page is last page", ->
      updateCurrentPage 5
      expect(getPaginationEl(-1)).not.toHaveClass "unavailable"
      expect(getPaginationEl(-1)).toHaveClass "current"

    it "changes currentPage if a page link is clicked", ->
      clickPaginationEl 1
      expect($rootScope.currentPage).toBe 2

    it "changes the number of items when total items changes", ->
      $rootScope.total = 73 # 8 pages
      $rootScope.$digest()
      expect(getPaginationBarSize()).toBe 8
      expect(getPaginationEl(0).text().trim()).toBe "1"
      expect(getPaginationEl(-1).text().trim()).toBe "8"


  describe "with just boundary & number links", ->
    beforeEach inject(->
      $rootScope.directions = false
      element = $compile("<pagination boundary-links=\"true\" direction-links=\"directions\" total-items=\"total\" current-page=\"currentPage\"></pagination>")($rootScope)
      $rootScope.$digest()
    )
    it "contains number of pages + 2 li elements", ->
      expect(getPaginationBarSize()).toBe 7
      expect(getPaginationEl(0).text().trim()).toBe "First"
      expect(getPaginationEl(1).text().trim()).toBe "1"
      expect(getPaginationEl(-2).text().trim()).toBe "5"
      expect(getPaginationEl(-1).text().trim()).toBe "Last"

    it "disables the \"first\" & activates \"1\" link if current page is 1", ->
      updateCurrentPage 1
      expect(getPaginationEl(0)).toHaveClass "unavailable"
      expect(getPaginationEl(1)).not.toHaveClass "unavailable"
      expect(getPaginationEl(1)).toHaveClass "current"

    it "disables the \"last\" & \"next\" link if current page is num-pages", ->
      updateCurrentPage 5
      expect(getPaginationEl(-2)).toHaveClass "current"
      expect(getPaginationEl(-2)).not.toHaveClass "unavailable"
      expect(getPaginationEl(-1)).toHaveClass "unavailable"


  describe "`num-pages`", ->
    beforeEach inject(->
      $rootScope.numpg = null
      element = $compile("<pagination total-items=\"total\" current-page=\"currentPage\" num-pages=\"numpg\"></pagination>")($rootScope)
      $rootScope.$digest()
    )
    it "equals to total number of pages", ->
      expect($rootScope.numpg).toBe 5

    it "changes when total number of pages change", ->
      $rootScope.total = 73 # 8 pages
      $rootScope.$digest()
      expect($rootScope.numpg).toBe 8

    it "shows minimun one page if total items are not defined and does not break binding", ->
      $rootScope.total = `undefined`
      $rootScope.$digest()
      expect($rootScope.numpg).toBe 1
      $rootScope.total = 73 # 8 pages
      $rootScope.$digest()
      expect($rootScope.numpg).toBe 8


  describe "setting `paginationConfig`", ->
    originalConfig = {}
    beforeEach inject((paginationConfig) ->
      angular.extend originalConfig, paginationConfig
      paginationConfig.itemsPerPage = 5
      paginationConfig.boundaryLinks = true
      paginationConfig.directionLinks = true
      paginationConfig.firstText = "FI"
      paginationConfig.previousText = "PR"
      paginationConfig.nextText = "NE"
      paginationConfig.lastText = "LA"
      element = $compile("<pagination total-items=\"total\" current-page=\"currentPage\"></pagination>")($rootScope)
      $rootScope.$digest()
    )
    afterEach inject((paginationConfig) ->
      
      # return it to the original stat
      angular.extend paginationConfig, originalConfig
    )
    it "should change paging text", ->
      expect(getPaginationEl(0).text().trim()).toBe "FI"
      expect(getPaginationEl(1).text().trim()).toBe "PR"
      expect(getPaginationEl(-2).text().trim()).toBe "NE"
      expect(getPaginationEl(-1).text().trim()).toBe "LA"

    it "contains number of pages + 4 li elements", ->
      expect(getPaginationBarSize()).toBe 14


  describe "override configuration from attributes", ->
    beforeEach inject(->
      element = $compile("<pagination boundary-links=\"true\" first-text=\"<<\" previous-text=\"<\" next-text=\">\" last-text=\">>\" total-items=\"total\" current-page=\"currentPage\"></pagination>")($rootScope)
      $rootScope.$digest()
    )
    it "contains number of pages + 4 li elements", ->
      expect(getPaginationBarSize()).toBe 9

    it "should change paging text from attribute", ->
      expect(getPaginationEl(0).text().trim()).toBe "<<"
      expect(getPaginationEl(1).text().trim()).toBe "<"
      expect(getPaginationEl(-2).text().trim()).toBe ">"
      expect(getPaginationEl(-1).text().trim()).toBe ">>"

