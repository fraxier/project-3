
class RemedyCli
  attr_accessor :header, :footer

  include Remedy

  def initialize(arr, header = Partial.new, footer = Partial.new)
    @viewport = Viewport.new
    @arr = arr
    @start = 0
    @header = header
    @footer = footer
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
      draw_arr_items
    end

  end

  def draw_arr_items(num = 10)
    @end = @start + num

    sub_arr = @arr.slice(@start, @end)
    part = Partial.new
    sub_arr.each do |item|
      part << item
    end
    @viewport.draw part, Size([0,0]), @header, @footer
  end

end