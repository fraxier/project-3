
class RemedyCli
  attr_accessor :header, :footer

  include Remedy

  def initialize(arr)
    @viewport = Viewport.new
    @arr = arr
    @max_num_viewable = 25
    @start = 0
    @end = @start + @max_num_viewable - 1
    @index = 0
  end

  # Provided from Remedy example
  def safe_setup
    ANSI.screen.safe_reset!
    ANSI.cursor.home!
    ANSI.command.clear_screen!
    Console.set_console_resized_hook! do |size|
      draw_arr_items
    end
  end


  def listen
    safe_setup

    interaction = Interaction.new
    draw_arr_items

    interaction.loop do |key|
      @last_key = key
      if key == "q" then
        interaction.quit!
      end
      if key.to_s == 'up'
        index_down
      end
      if key.to_s == 'down'
        index_up
      end
      draw_arr_items
    end

  end

  def index_up
    if @index < @arr.length - 1
      @index += 1
      if @index == @end + 1 && @end < @arr.length - 1
        @end += 1
        @start += 1
      end
    end
  end

  def index_down
    if @index > 0
      @index -= 1
      if @index == @start && @start > 0
        @end -= 1
        @start -= 1
      end
    end
  end

  def draw_arr_items
   
    part = Partial.new

    for i in @start..@end do
      item = @arr[i]
      if i == @index
        part << "#{item.to_s.colorize(:blue)}"
      else
        part << "#{item.to_s.colorize(:red)}"
      end
    end

    update_header_footer

    @viewport.draw part, Size([0,0]), @header, @footer
  end

  def update_header_footer
    @header = Partial.new
    @header << 'Viewing results from search'
    @header << 'Press Enter on a result to find more information about it'
    @footer = Partial.new
    @footer << "There are #{@arr.length} results, viewing #{@start + 1} - #{@end + 1}"
    @footer << @last_key.to_s
    @footer << @index
  end

end