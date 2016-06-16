class @Newstime.MastheadView extends @Newstime.View

  initialize: (options) ->
    @composer = options.composer
    @edition = @composer.edition

    @model = new Backbone.Model()

    @$mastheadArtworkImg = @$('.masthead-artwork img')

    height = @height()

    artworkHeight = parseInt(@$mastheadArtworkImg.css('height'))
    @artworkHeightDifference = height - artworkHeight

    @model.set
      top: @top()
      left: @left()
      width: @width()
      height: height
      artwork_height: height - @artworkHeightDifference

    @propertiesView ?= @_createPropertiesView()

    @outlineView = @composer.outlineViewCollection.add
                     model: @model

    @listenTo @model, 'change', @render


    @bindUIEvents()

  render: ->
    @$mastheadArtworkImg.css height: @model.get('artwork_height')

    #console.log @model.pick('height')

  getPropertiesView: ->
    @propertiesView

  top: ->
    @$el.position()['top']
    #@el.offsetTop

  left: ->
    @$el.position()['left']

  width: ->
    parseInt(@$el.css('width'))

  height: ->
    parseInt(@$el.css('height'))

  geometry: ->
    y: @top()
    x: @left()
    width: @width()
    height: @height()

  dragBottom: (x, y) ->

    #@model.set
      #height: @pageView.snapBottom(y) - geometry.top

    @model.set
      height: y - @top()
      artwork_height: y - @top() - @artworkHeightDifference

  mouseover: (e) ->
    #@model.set
      #top: @top()
      #left: @left()
      #width: @width()
      #height: @height()

    @outlineView.show()

  mouseout: (e) ->
    @outlineView.hide()

  mousedown: (e) ->
    #@composer.select(this)
    @composer.selectMasthead(this)

  select: (selectionView) ->
    unless @selected
      @selected = true
      @selectionView = selectionView
      @trigger 'select',
        contentItemView: this
        contentItem: @model

  deselect: ->
    if @selected
      @selected = false
      @selectionView = null
      @trigger 'deselect', this

  dblclick: ->
    #alert 'Pick an image'

  _createPropertiesView: ->
    new Newstime.MastheadPropertiesView(target: this, model: @model)