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
