class @Newstime.MastheadView extends @Newstime.View

  initialize: (options) ->
    @composer = options.composer
    @edition = @composer.edition

    @model = new Backbone.Model()

    @model.set('lock', @edition.get('masthead_artwork_attributes').lock)

    @$mastheadArtworkImg = @$('.masthead-artwork img')

    height = @height()

    artworkHeight = parseInt(@$mastheadArtworkImg.css('height'))
    @artworkHeightDelta = height - artworkHeight

    @model.set
      top: @top()
      left: @left()
      width: @width()
      height: height
      artwork_height: height - @artworkHeightDelta

    @propertiesView ?= @_createPropertiesView()

    @outlineView = @composer.outlineViewCollection.add
                     model: @model

    @listenTo @model, 'change', @render
    @listenTo @model, 'change:lock', @changeLock

    # Handle before-save event on composer to copy over changed attributes to
    # the edition for saving...
    @listenTo @composer, 'before-save', @beforeSave


    @bindUIEvents()

  render: ->
    @$mastheadArtworkImg.css height: @model.get('artwork_height')

  beforeSave: ->
    # Copy over masthead artwork height to edition.masthead_artwork
    @edition.get('masthead_artwork_attributes').height = @model.get('artwork_height')
    @edition.get('masthead_artwork_attributes').lock = @model.get('lock')

    # TODO: If artwork was change, post it to the server now...

  keydown: (e) =>
    switch e.keyCode
      when 27 # ESC
        @deselect()

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

  setHeight: (height) ->
    @model.set
      height: height
      artwork_height: height - @artworkHeightDelta

  geometry: ->
    y: @top()
    x: @left()
    width: @width()
    height: @height()

  dragBottom: (x, y) ->
    @setHeight(y - @top())


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
    unless @model.get('lock') # Do nothing if lock is set.
      $fileInput = $('<input type="file">')
      $fileInput.click()

      $fileInput.change (e) =>
        reader = new FileReader()
        console.log e.target.files
        reader.onload = (e) =>
          @$mastheadArtworkImg.attr 'src', e.target.result

        reader.readAsDataURL(e.target.files[0])

    #alert 'Pick an image'

  _createPropertiesView: ->
    new Newstime.MastheadPropertiesView(target: this, model: @model)
