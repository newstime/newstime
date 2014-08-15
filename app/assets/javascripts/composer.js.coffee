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

    #var composerModals = $(".composer-modal"),
    #contentRegionModal = $(".add-content-region"),
    #contentItemModal = $(".add-content-item").contentModal();
    eventCaptureScreen = new Newstime.EventCaptureScreen()
    headlineProperties = new Newstime.HeadlinePropertiesView()
    globalKeyboardDispatch = new Newstime.GlobalKeyboardDispatch()
    Newstime.Composer.globalKeyboardDispatch = globalKeyboardDispatch
    Newstime.Composer.keyboard = new Newstime.Keyboard(defaultFocus: globalKeyboardDispatch)

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

    $("[page-compose]").each (i, el) ->
      new Newstime.PageComposeView(
        el: el
        eventCaptureScreen: eventCaptureScreen
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
    return

  captureAuthenticityToken: ->
    @authenticityToken = $("input[name=authenticity_token]").first().val()
    return

  toggleGridOverlay: ->
    @gridOverlay.toggle()
    return

$ ->
  Newstime.Composer.init()
  return
