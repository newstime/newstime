class EntriesController < ApplicationController

  # Parameters
  #
  #   days_ago - Interger value of number of days to go back.
  def index
    topic = params[:topic]
    date = Date.today - params[:days_ago].to_i.days
    #date = Date.parse('2013/12/7')

    # Normalize date

    root_path = "#{NOTES_ROOT}/entries/"

    if topic
      # TODO: Watch out for use passing in a relative path that can get out of
      # the directory. I'll have to look into this more.
      root_path = "#{NOTES_ROOT}/#{topic}/entries/"
    end

    today_path = "#{root_path}/#{date.strftime("%Y/%m/%d")}"
    todays_entries = Dir["#{today_path}/*.txt"]

    @entries = todays_entries.map { |full_path|
      path, ext = full_path.match(/#{root_path}(.*)\.(txt)$/).try(:captures)
      created_at = parse_created_at("#{path}.#{ext}")

      markdown = File.read(full_path)
      front_matter, _markdown = markdown.match(/---((.|\n)*)---((.|\n)*)/).try(:captures)
      if front_matter
        front_matter = YAML.load(front_matter)
        markdown = markdown.gsub(/---(.|\n)*---/, '') # Strip front matter
      end

      attributes = {
        path: path,
        markdown: markdown,
        html: $markdown.render(markdown),
        created_at: created_at,
        formatted_date: created_at.strftime('%A, %B %e %Y'),
        formatted_time: created_at.strftime('%I:%M %p'),
        formatted_date_time: created_at.strftime('%A, %B %e, %Y, %l:%M %p')
      }
      OpenStruct.new(attributes)
    }
    @entries.reverse!
  end

  def show
    root_path = "/Users/blake/.notes/entries/"
    path = params[:path]
    full_path = root_path + path

    created_at = parse_created_at(path)

    markdown = File.read(full_path + '.txt')
    front_matter, _markdown = markdown.match(/---((.|\n)*)---((.|\n)*)/).try(:captures)
    if front_matter
      front_matter = YAML.load(front_matter)
      markdown = markdown.gsub(/---(.|\n)*---/, '') # Strip front matter
    end

    attributes = {
      path: path,
      markdown: markdown,
      html: $markdown.render(markdown),
      created_at: created_at,
      formatted_date: created_at.strftime('%A, %B %e %Y'),
      formatted_time: created_at.strftime('%I:%M %p'),
      formatted_date_time: created_at.strftime('%A, %B %e, %Y, %l:%M %p')
    }
    @entry = OpenStruct.new(attributes)
    respond_to do |format|
      format.html
      format.text { render text: markdown }
    end
  end

  def edit
    root_path = "/Users/blake/.notes/entries/"
    path = params[:path]
    full_path = root_path + path

    created_at = parse_created_at(path)
    markdown = File.read(full_path + '.txt')
    attributes = {
      path: path,
      markdown: markdown,
      html: $markdown.render(markdown),
      created_at: created_at,
      formatted_date: created_at.strftime('%A, %B %e %Y'),
      formatted_time: created_at.strftime('%I:%M %p'),
      formatted_date_time: created_at.strftime('%A, %B %e, %Y, %l:%M %p')
    }
    @entry = OpenStruct.new(attributes)
  end

  def update
    render text: 'hold tight'
  end

private

  def parse_created_at(path)
    # Parse created at
    #2013/23/23/23:23:23.txt'
    date, time = path.match(/(\d{2,4}\/\d{1,2}\/\d{1,2})\/(\d{1,2}\:\d{1,2}\:\d{1,2})/).try(:captures)
    Time.parse("#{date} #{time}") # Might need some conrrection for timezone.
  end

end
