# View layer which manages display and interaction with panels
class @Newstime.PanelLayerView extends Backbone.View

  initialize: (options) ->
    @$el.addClass 'panel-layer-view'
    @panels ?= []

    # Until we have a better means of containg all the application layer, just
    # using this simple means to offset from the top.
    @topOffset = options.topOffset
    @$el.css top: "#{@topOffset}px"

    @bind 'mouseover',  @mouseover
    @bind 'mouseout',   @mouseout
    @bind 'mousemove',  @mousemove
    @bind 'mousedown',  @mousedown
    @bind 'mouseup',    @mouseup

  attachPanel: (panel) ->
    # Push onto the panels collection.
    @panels.push panel

    panel.bind 'tracking', @tracking, this
    panel.bind 'tracking-release', @trackingRelease, this

    # Attach it to the dom el
    @$el.append(panel.el)

  # Registers hit, and returns hit panel, should there be one.
  hit: (x, y) ->

    e =
      x: x
      y: y
    # Received a mousedown event, check for a hit and to see if we need to pass
    # on to a panel.

    # Check against panels.
    # Panel are assumed to be in order from top most first (When selected, a
    # panel is moved to the top visually and in this stack

    panel = _.find @panels, (panel) =>
      @detectHit panel, x, y


    if @hovered # Only process events if hovered.
      if panel
        if @hoveredObject != panel
          if @hoveredObject
            @hoveredObject.trigger 'mouseout', e
          @hoveredObject = panel
          @hoveredObject.trigger 'mouseover', e

        return true
      else
        if @hoveredObject
          @hoveredObject.trigger 'mouseout', e
          @hoveredObject = null

        return false

    else
      if panel
        # Defer processing of events until we are declared the hovered object.
        @hoveredObject = panel
        return true
      else
        return false

  detectHit: (panel, x, y) ->
    # Get panel geometry
    geometry = panel.geometry()

    # Expand the geometry by buffer distance in each direction to extend
    # clickable area.
    buffer = 4 # 2px
    geometry.x -= buffer
    geometry.y -= buffer
    geometry.width += buffer*2
    geometry.height += buffer*2

    # Detect if corrds lie within the geometry
    if x >= geometry.x && x <= geometry.x + geometry.width
      if y >= geometry.y && y <= geometry.y + geometry.height
        return true

    return false

  mouseover: (e) ->
    @hovered = true

    if @hoveredObject
      @hoveredObject.trigger 'mouseover', e

  mouseout: (e) ->
    @hovered = false

    if @hoveredObject
      @hoveredObject.trigger 'mouseover', e
      @hoveredObject = null


  mousedown: (e) ->
    if @hoveredObject
      @hoveredObject.trigger 'mousedown', e

  mouseup: (e) ->
    if @hoveredObject
      @hoveredObject.trigger 'mouseup', e

  mousemove: (e) ->
    if @hoveredObject
      @hoveredObject.trigger 'mousemove', e


  tracking: (panel) ->
    @trackingPanel = panel
    @trigger 'tracking', this

  trackingRelease: (panel) ->
    @trackingPanel = null
    @trigger 'tracking-release', this
