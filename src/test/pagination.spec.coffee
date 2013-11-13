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

  clickPaginationEl = (index) ->
    getPaginationEl(index).find('a').click()

  updateCurrentPage = (value) ->
    $rootScope.currentPage = value
    $rootScope.$digest()

  it 'has a "pagination" css class on ul', ->
    expect(element.find('ul').hasClass('pagination')).toBe(true)

  it 'contains one ul and num-pages li elements', ->
    expect(element.find('ul').length).toBe(1) # работает
    expect(element.find('li').length).toBe(7) # работает
    console.log(getPaginationEl(0))
    expect(getPaginationEl(0).text()).toBe('Previous') # не выполняется, пишет что текст это пустота
    expect(getPaginationEl(-1).text()).toBe('Next') # таже хрень

  # it 'sets the current page to be active', ->
  #   expect(getPaginationEl($rootScope.currentPage).hasClass('active')).toBe(true)