class GChartBase
  API_URL = 'http://chart.apis.google.com/chart?'

  def initialize
    @chart_type = nil
    @width = 250
    @height = 100
    @data = []
    @labels = []
    @auto_scale = false
    @scale_low = nil
    @scale_high = nil
    @title = nil
    @title_color = nil
    @title_size = nil
    @axis_left = nil
    @axis_right = nil
    @axis_top = nil
    @axis_botto = nil
  end

  def scale_data!(data_points, options = {})
    range_low = nil
    range_high = nil

    if options
      range_low = options[:min] if options[:min]
      range_high = options[:high] if options[:high]
    end

    range_low = data_points.min unless range_low
    range_high = data_points.max unless range_high

    range = range_high - range_low
    scale = 100.0 / range

    data_points.map! do |dp|
      dp = (dp - range_low) * scale
      # round to 2 decimal places
      dp = (dp * 100.0).round / 100.0
    end
  end

  def data_set(options = {})
    @data = options[:data] if options[:data]
    @labels = options[:labels] if options[:labels]
  end

  def auto_scale(options = {})
    @auto_scale = true
    @scale_low = 0 if options[:start_zero]
    @scale_low = options[:scale_low] if options[:scale_low]
    @scale_high = options[:scale_high] if options[:scale_high]
  end

  def title(title, options = {})
    @title = title
    @title_color = options[:color] if options[:color]
    @title_size = options[:size] if options[:size]
  end

  def title_color(color)
    @title_color = color
  end

  def title_size(size)
    @title_size = size
  end

  def enable_left_axis
    @axis_left = true
  end

  def enable_right_axis
    @axis_right = true
  end

  def enable_top_axis
    @axis_top = true
  end

  def enable_bottom_axis
    @axis_bottom = true
  end

  def enable_axis(options = {})
    @axis_left = true if options[:left]
    @axis_right = true if options[:right]
    @axis_top = true if options[:top]
    @axis_bottom = true if options[:bottom]
  end

  # these methods change the settings into URL parameters
  def axis_type_to_url
    if @axis_left || @axis_right || @axis_bottom || @axis_top
      res = []
      res << 'x' if @axis_bottom
      res << 't' if @axis_top
      res << 'y' if @axis_left
      res << 'r' if @axis_right

      return "&chxt=#{res * ','}"
    else
      return ''
    end
    
  end

  def chart_type_to_url
    "cht=#{@chart_type}"
  end

  def size_to_url
    "&chs=#{@width}x#{@height}"
  end

  def data_to_url
    scale_data!(@data, :min => @scale_low) if @auto_scale
    "&chd=t:#{@data * ','}"
  end

  def title_to_url
    res = ''
    if @title
      res += "&chtt=#{@title}"
      if @title_color
        res += "&chts=#{@title_color}"
        res += ",#{@title_size}" if @title_size
      end
    end

    return res
  end

  def to_url(html_options = {})
    api_call = API_URL + chart_type_to_url + size_to_url + data_to_url + title_to_url + axis_type_to_url
    res  = '<img src="' + api_call + '" '
    res += 'class="' + html_options[:class] + '" ' if html_options[:class]
    res += 'id="' + html_options[:id] + '" ' if html_options[:id]
    res += '/>'

    return res
  end
end

class GChartLineBase < GChartBase
  def initialize
    super
    @chart_type = 'l'
  end
end

class GChartLine < GChartLineBase
  def initialize
    super
    @chart_type = 'lc'
  end
end

class GChartSparkLine < GChartLineBase
  def initialize
    super
    @chart_type = 'ls'
  end
end

class GChartXYLine < GChartLineBase
  def initialize
    super
    @chart_type = 'lxy'
  end
end

class GChart < GChartBase
  def self.line(html_options = {})
    yield c = GChartLine.new

    puts c.to_url(html_options)
  end
end

# this is some test code
puts '<html><body>'

GChart.line(:class => 'line_charts') do |l|
  l.data_set :data => [100,20,100,300] 
  l.auto_scale :start_zero => true
  l.title 'My test chart', :color => 'ff0000', :size => 15
  l.enable_axis :left => true, :bottom => true
end

puts '</body></html>'
