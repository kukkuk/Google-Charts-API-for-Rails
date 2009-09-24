class GChartBase
  API_URL = 'http://chart.apis.google.com/chart?'

  def initialize
    @chart_type = nil
    @width = 250
    @height = 100
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
    scale = 100 / range

    data_points.map! do |dp|
      dp = (dp - range_low) * scale
    end
  end

  def chart_type_to_url
    "cht=#{@chart_type}"
  end

  def size_to_url
    "&chs=#{@width}x#{@height}"
  end

  def to_url
    API_URL + chart_type_to_url + size_to_url
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

class GChart
  def self.line
    yield c = GChartLine.new

    puts c.to_url
  end
end


GChart.line do |l|
end

