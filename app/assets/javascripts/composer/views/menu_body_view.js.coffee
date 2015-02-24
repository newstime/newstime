class @Newstime.MenuBodyView extends Newstime.View

  initialize: (options) ->
    @$el.addClass "menu-body"

    @$el.hide()

    @model = new Backbone.Model()

    @composer = Newstime.composer

    @listenTo @model, 'change', @render
    @render()

  render: ->
    @$el.css @model.pick 'top', 'left'

  open: ->
    @$el.show()

  close: ->
    @$el.hide()
