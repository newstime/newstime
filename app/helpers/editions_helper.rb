module EditionsHelper
  attr_reader *[
    :layout_module,
    :edition,
    :section,
    :composing,
    :template_name,
    :title
  ]

  attr_accessor :layouts

  alias :composing? :composing

  def layouts
    @layouts ||= []
  end

  def wrap_with(*args)
    layouts << args
  end

  def yield_content(&block)
    content = capture(&block)

    # Decorate view with layout module particularities.
    view = LayoutModule::View.new(self)

    while layout = layouts.pop
      template_name = layout.shift
      template = layout_module.templates[template_name]
      content = template.render(view, *layout) { content }.html_safe
    end

    concat(content)
  end

  # TODO: In time, this logic should be reverse to not rely on exceptions and to
  # check with the layout module first to allow more flexiable overriding.
  def render(name, *args)
    super(name, *args)
  rescue ActionView::MissingTemplate
    view = LayoutModule::View.new(self)
    template = layout_module.templates[name]
    template.render(view, *args).html_safe
  end

  def composer_stylesheet
    stylesheet_link_tag("composer") + "\n"
  end

  def composer_javascript
    content = content_for(:composer_variables)
    content << javascript_include_tag("composer") + "\n"
  end

  def render_content_items(content_region, options={})
    column_width = options[:column_width] || 34 # Standin values
    gutter_width = options[:gutter_width] || 16

    content = ""
    content_region.content_items.each do |content_item|

      content << case content_item
      when Content::HeadlineContentItem then
        render "content/headline", id: content_item.id,
          text: content_item.text,
          style: content_item.style
      when Content::StoryTextContentItem then
        options = {}
        options[:id]       = content_item.id
        options[:story]    = content_item.story
        options[:width]    = content_item.width
        options[:height]   = content_item.height
        options[:columns]  = content_item.columns

        # Compute column width of individual text columns
        text_column_width = (content_item.width - ((content_item.columns - 1) * gutter_width)) / content_item.columns
        options[:text_column_width]  = text_column_width

        render "content/story", options
      when Content::PhotoContentItem then
        options = {}
        options[:id]            = content_item.id
        options[:photo_url]     = content_item.photo_url
        options[:photo_width]   = content_region.width
        options[:photo_height]  = content_region.width / content_item.photo.aspect_ratio
        render "content/photo", options
      when Content::VideoContentItem then
        render "content/video", options
      end
    end
    content
  end
end
