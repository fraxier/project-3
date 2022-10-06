# rubocop:disable Metrics/MethodLength

class RemedyCli
  attr_accessor :header, :footer, :search_results

  include Remedy

  def initialize
    @viewport = Viewport.new

    @index = 0
    @max_num_viewable = 25
    @start = 0
    @end = @start + @max_num_viewable - 1
  end

  # Provided from Remedy example
  def safe_setup
    ANSI.screen.safe_reset!
    ANSI.cursor.home!
    ANSI.command.clear_screen!
    Console.set_console_resized_hook! do |size|
    end
  end

  def listen
    safe_setup
    @interaction = Interaction.new
    welcome_menu
    searcher = Searcher.new self
    @interaction.loop do |key|
      @interaction.quit! if key == 'q'
      searcher.construct_search
    end
  end

  # TODO: create the actual menu logic
  def welcome_menu
    quick_draw(
      msg: 'Welcome to the Steam Store CLI (unofficial)!',
      header_msg: "The time is: #{Time.now}",
      footer_msg: "Screen size: #{Console.size} You pressed: #{@last_key}"
    )
  end

  def navigate_results
    looping = true
    while looping
      draw_arr_items
      key = chomp_key
      index_down if key.to_s == 'up'
      index_up if key.to_s == 'down'
    end
  end

  def index_up
    if @index < @search_results.length - 1
      @index += 1
      if @index == @end + 1 && @end < @search_results.length - 1
        @end += 1
        @start += 1
      end
    end
  end

  def index_down
    if @index.positive?
      @index -= 1
      if @index == @start && @start.positive?
        @end -= 1
        @start -= 1
      end
    end
  end

  # rubocop:disable Style/For
  def draw_arr_items
    part = Partial.new
    for i in @start..@end do
      game = @search_results[i]
      part << if i == @index
                game.pretty_string.colorize(:blue)
              else
                game.pretty_string.colorize(:red)
              end
    end
    update_header_footer
    draw part
  end
  # rubocop:enable Style/For

  def quick_draw(msg:, header_msg: '', footer_msg: '')
    new_header [header_msg].flatten
    new_footer [footer_msg].flatten
    draw new_part([msg].flatten)
  end

  def chomp_key
    key = @interaction.get_key
    @interaction.quit! if key == 'q'
    key
  end

  private

  def draw(part)
    @viewport.draw part, Size([0, 0]), @header, @footer
  end

  def new_part(msgs_arr)
    part = Partial.new
    msgs_arr.each { |msg| part << msg }
    part
  end

  def new_header(msgs_arr)
    @header = Partial.new
    msgs_arr.each { |msg| @header << msg.colorize(:green) }
  end

  def new_footer(msgs_arr)
    @footer = Partial.new
    msgs_arr.each { |msg| @footer << msg.colorize(:yellow) }
  end

  def update_header_footer
    new_header [
      'Viewing results from search',
      'Press Enter on a result to find more information about it'
    ]
    new_footer [
      "There are #{@search_results.length} results, viewing #{@start + 1} - #{@end + 1}",
      "Current index: #{@index}",
      'Press Q to quit'
    ]
  end
end

# rubocop:enable Metrics/MethodLength
