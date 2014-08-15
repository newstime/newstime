# ## Libraries
#= require lib/zepto
#= require lib/underscore
#= require lib/backbone
#= require faye
#
# ## App
#= require newstime_util
#= require_tree ./composer/plugins
#= require_tree ./composer/models
#= require_tree ./composer/views

@Newstime = @Newstime or {}

@Newstime.Composer =
  init: ->
    @captureAuthenticityToken()

    #@eventEmitter = new Newstime.EventEmitter (Mouse events, Keyboard Events,
    #Scroll Events)

    #var composerModals = $(".composer-modal"),
    #contentRegionModal = $(".add-content-region"),
    #contentItemModal = $(".add-content-item").contentModal();

    @eventCaptureScreen = new Newstime.EventCaptureScreen
      topOffset: '62px'

    headlineProperties = new Newstime.HeadlinePropertiesView()

    @globalKeyboardDispatch = new Newstime.GlobalKeyboardDispatch() # Handler


    canvasDragView = new Newstime.CanvasDragView
      composer: this

    @globalKeyboardDispatch.bind 'dragModeEngaged', ->
      canvasDragView.engage()

    @globalKeyboardDispatch.bind 'dragModeDisengaged', ->
      canvasDragView.disengage()


    Newstime.Composer.globalKeyboardDispatch = @globalKeyboardDispatch
    Newstime.Composer.keyboard = new Newstime.Keyboard(defaultFocus: @globalKeyboardDispatch)
    #keyboard.pushFocus(textRegion) // example

    # Initialize Plugins
    $("#edition-toolbar").editionToolbar()
    $("#section-nav").sectionNav()
    $("[headline-control]").headlineControl headlineProperties
    storyPropertiesView = new Newstime.StoryPropertiesView()
    $("[story-text-control]").each (i, el) ->
      new Newstime.StoryTextControlView(
        el: el
        toolPalette: storyPropertiesView
      )
      return

    contentRegionPropertiesView = new Newstime.ContentRegionPropertiesView()
    $("[content-region-control]").each (i, el) ->
      new Newstime.ContentRegionControlView(
        el: el
        propertiesView: contentRegionPropertiesView
      )
      return

    photoPropertiesView = new Newstime.PhotoPropertiesView()
    $("[photo-control]").each (i, el) ->
      new Newstime.PhotoControlView(
        el: el
        propertiesView: photoPropertiesView
      )
      return

    $("[page-compose]").each (i, el) =>
      new Newstime.PageComposeView(
        el: el
        eventCaptureScreen: @eventCaptureScreen
      )
      return

    #$(".add-page-btn").addPageButton()
    #$(".add-content-region-btn").addContentRegionButton(contentRegionModal)
    #$(".add-content-btn").addContentButton(contentItemModal)

    #$(".composer-modal-dismiss").click(function(){
    #composerModals.addClass("hidden");
    #});

    # Create Vertical Rule
    #verticalRulerView = new Newstime.VerticalRulerView()
    #$('body').append(verticalRulerView.el);

    #log = console.log;  // example code, delete if you will.
    #console.log = function(message) {
    #log.call(console, message);
    #}
    #console.log("Tapping into console.log");

    @gridOverlay = $(".grid-overlay").hide()
    toolboxView = new Newstime.ToolboxView()
    toolboxView.show()

    #var zoomHandeler = new Newstime.ZoomHandler()
    #Newstime.Composer.zoomHandler = zoomHandeler
    ctrlZoomHandeler = new Newstime.CtrlZoomHandler()
    Newstime.Composer.ctrlZoomHandler = ctrlZoomHandeler

    # Wire Up events
    @eventCaptureScreen.bind 'mousedown', (e) =>
      @mousedown(e)


  captureAuthenticityToken: ->
    @authenticityToken = $("input[name=authenticity_token]").first().val()
    return

  toggleGridOverlay: ->
    @gridOverlay.toggle()
    return

  hideCursor: ->
    @eventCaptureScreen.hideCursor()

  showCursor: ->
    @eventCaptureScreen.showCursor()

  mousedown: (e) ->
    # We've received a mouse down event!
    # Figure out where to send the event

    # Forward to child objects.
    @children ?= []
    @children.push 3
    console.log @children

    # As we search through the children, the uppermost object should be the
    # first to receive. We will map the click based on zoom level and scroll,
    # and see if there is a click. We must realize that this click is actually
    # received on the view port (Event capture region), and there is the canvas
    # which is the total area. The panels are above, and perhaps shouldn't be
    # thought of as children, and are infact panels, that can be hit


$ ->
  Newstime.Composer.init()
  return
