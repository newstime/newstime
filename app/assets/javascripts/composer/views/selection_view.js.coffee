@Newstime = @Newstime || {}

class @Newstime.SelectionView extends Backbone.View

  initialize: (options) ->
    @$el.addClass 'selection-view'
    @page = options.page
    @composer = options.composer

    # Add drag handles
    @dragHandles = ['top', 'top-right', 'right', 'bottom-right', 'bottom', 'bottom-left', 'left', 'top-left']
    @dragHandles = _.map @dragHandles, (type) ->
      new Newstime.DragHandle(selection: this, type: type)

    # Attach handles
    handleEls = _.map @dragHandles, (handle) -> handle.el
    @$el.append(handleEls)

    # Listen for model changes
    @model.bind 'change', @modelChanged, this

    @bind 'mousedown', @mousedown
    @bind 'mousemove', @mousemove
    @bind 'mouseup',   @mouseup
    @bind 'mouseover', @mouseover
    @bind 'mouseout',  @mouseout

    @$el.css _.pick @model.attributes, 'top', 'left', 'width', 'height'

  modelChanged: ->
    @$el.css _.pick @model.changedAttributes(), 'top', 'left', 'width', 'height'

  activate: ->
    @active = true
    @trigger 'activate', this
    @$el.addClass 'resizable'

  deactivate: ->
    @active = false
    @trigger 'deactivate', this
    @$el.removeClass 'resizable'

  # Detects a hit of the selection
  hit: (x, y) ->

    geometry = @getGeometry()

    ## Expand the geometry by buffer distance in each direction to extend
    ## clickable area.
    buffer = 4 # 2px
    geometry.top -= buffer
    geometry.left -= buffer
    geometry.width += buffer*2
    geometry.height += buffer*2

    ## Detect if corrds lie within the geometry
    geometry.left <= x <= geometry.left + geometry.width &&
      geometry.top <= y <= geometry.top + geometry.height

  beginSelection: (x, y) ->
    # Snap x to grid
    x = @page.snapLeft(x)

    @model.set
      left: x
      top: y

    @activate()
    @trackResize("bottom-right") # Begin tracking for size

  getLeft: ->
    @model.get('left')
    #parseInt(@$el.css('left'))

  getTop: ->
    @model.get('top')
    #parseInt(@$el.css('top'))

  getWidth: ->
    @model.get('width')
    #parseInt(@$el.css('width'))

  getHeight: ->
    @model.get('height')
    #parseInt(@$el.css('height'))

  getGeometry: ->
    @model.pick('top', 'left', 'height', 'width')

  mousedown: (e) ->
    x = e.x
    y = e.y

    unless @active
      @activate()

    geometry = @getGeometry()

    # If active, check against the drag handles
    # TODO: Drag handels need to become a hovered target, then if there is
    # hovered object, we can delegate down, or handle locally by entering a
    # move.
    if @active

      width   = geometry.width
      height  = geometry.height
      top     = geometry.top
      left    = geometry.left

      right   = left + width
      bottom  = top + height
      centerX = left + width/2
      centerY = top + height/2

      if @hitBox x, y, centerX, top, 8
        @trackResize "top"
        return false # Cancel event

      # right drag handle hit?
      if @hitBox x, y, right, centerY, 8
        @trackResize "right"
        return false # Cancel event

      # left drag handle hit?
      if @hitBox x, y, left, centerY, 8
        @trackResize "left"
        return false # Cancel event

      # bottom drag handle hit?
      if @hitBox x, y, centerX, bottom, 8
        @trackResize "bottom"
        return false # Cancel event

      # top-left drag handle hit?
      if @hitBox x, y, left, top, 8
        @trackResize "top-left"
        return false # Cancel event

      # top-right drag handle hit?
      if @hitBox x, y, right, top, 8
        @trackResize "top-right"
        return false # Cancel event

      # bottom-left drag handle hit?
      if @hitBox x, y, left, bottom, 8
        @trackResize "bottom-left"
        return false # Cancel event

      # bottom-right drag handle hit?
      if @hitBox x, y, right, bottom, 8
        @trackResize "bottom-right"
        return false # Cancel event

      ## Expand the geometry by buffer distance in each direction to extend
      ## clickable area.
      buffer = 4 # 2px
      geometry.left -= buffer
      geometry.top -= buffer
      geometry.width += buffer*2
      geometry.height += buffer*2

      ## Detect if corrds lie within the geometry
      if geometry.left <= x <= geometry.left + geometry.width &&
        geometry.top <= y <= geometry.top + geometry.height
          @trackMove(x - geometry.left, y - geometry.top)
          return false

    return true

  trackResize: (mode) ->
    @resizing   = true
    @resizeMode = mode

    switch @resizeMode
      when 'top', 'top-left', 'top-right'
        @page.computeTopSnapPoints()

      when 'bottom', 'bottom-left', 'bottom-right'
        @page.computeBottomSnapPoints()

    @trigger 'tracking', this

  trackMove: (offsetX, offsetY) ->
    @page.computeTopSnapPoints()
    @moving      = true
    @moveOffsetX = offsetX
    @moveOffsetY = offsetY
    @trigger 'tracking', this

  mousemove: (e) ->
    if @resizing
      switch @resizeMode
        when 'top'          then @dragTop(e.x, e.y)
        when 'right'        then @dragRight(e.x, e.y)
        when 'bottom'       then @dragBottom(e.x, e.y)
        when 'left'         then @dragLeft(e.x, e.y)
        when 'top-left'     then @dragTopLeft(e.x, e.y)
        when 'top-right'    then @dragTopRight(e.x, e.y)
        when 'bottom-left'  then @dragBottomLeft(e.x, e.y)
        when 'bottom-right' then @dragBottomRight(e.x, e.y)

    else if @moving
      @move(e.x, e.y)

  # Moves based on corrdinates and starting offset
  move: (x, y) ->
    geometry = @getGeometry()
    x = @page.snapLeft(x - @moveOffsetX)
    y = @page.snapTop(y - @moveOffsetY)
    @model.set
      left: x
      top: y

  # Resizes based on a top drag
  dragTop: (x, y) ->
    geometry = @getGeometry()
    y = @page.snapTop(y)
    @model.set
      top: y
      height: geometry.top - y + geometry.height

  dragRight: (x, y) ->
    geometry = @getGeometry()
    width = @page.snapRight(x - geometry.left)
    @model.set
      width: width

  dragBottom: (x, y) ->
    geometry = @getGeometry()
    @model.set
      height: @page.snapBottom(y) - geometry.top

  dragLeft: (x, y) ->
    geometry = @getGeometry()
    x        = @page.snapLeft(x)
    @model.set
      left: x
      width: geometry.left - x + geometry.width

  dragTopLeft: (x, y) ->
    geometry = @getGeometry()
    x        = @page.snapLeft(x)
    y        = @page.snapTop(y)
    @model.set
      left: x
      top: y
      width: geometry.left - x + geometry.width
      height: geometry.top - y + geometry.height

  dragTopRight: (x, y) ->
    geometry = @getGeometry()
    width = @page.snapRight(x - geometry.left)
    y = @page.snapTop(y)
    @model.set
      top: y
      width: width
      height: geometry.top - y + geometry.height

  dragBottomLeft: (x, y) ->
    geometry = @getGeometry()
    x = @page.snapLeft(x)
    y = @page.snapBottom(y)
    @model.set
      left: x
      width: geometry.left - x + geometry.width
      height: y - geometry.top

  dragBottomRight: (x, y) ->
    geometry = @getGeometry()
    width = @page.snapRight(x - geometry.left)
    y = @page.snapBottom(y)
    @model.set
      width: width
      height: y - geometry.top

  mouseup: (e) ->
    @resizing = false
    @moving = false
    @trigger 'tracking-release', this

  mouseover: (e) ->
    @hovered = true
    @$el.addClass 'hovered'
    @composer.pushCursor @getCursor()

  getCursor: ->
    'default'

  mouseout: (e) ->
    @hovered = false
    @$el.removeClass 'hovered'
    @composer.popCursor()

  # Does an x,y corrdinate intersect a bounding box
  hitBox: (hitX, hitY, boxX, boxY, boxSize) ->
    boxLeft   = boxX - boxSize
    boxRight  = boxX + boxSize
    boxTop    = boxY - boxSize
    boxBottom = boxY + boxSize

    boxLeft <= hitX <= boxRight &&
      boxTop <= hitY <= boxBottom
