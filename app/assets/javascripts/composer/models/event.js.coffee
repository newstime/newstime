class @Newstime.Event
  constructor: (orginalEvent) ->
    @orginalEvent = orginalEvent

    if @orginalEvent?
      @x = @orginalEvent.x
      @y = @orginalEvent.y
      @button = @orginalEvent.button

  stopPropagation: ->
    # Pass call through to orginal event
    @orginalEvent.stopPropagation()

  preventDefault: ->
    # Pass call through to orginal event
    @orginalEvent.preventDefault()
