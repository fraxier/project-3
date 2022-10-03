class RemedyCli
  attr_accessor :header, :footer

  include Remedy

  def initialize
    @viewport = Viewport.new
    @controller = StorePageController.new
    @welcomed = false

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
    interaction = Interaction.new
    ANSI.cursor.show!
    welcome unless @welcomed
    interaction.loop do |key|
      @last_key = key
      interaction.quit! if key == 'q'
      construct_search interaction
      # navigate_results
    end
  end

  def test_stuff(interaction)
    looping = true
    while looping
      part = Partial.new
      part << 'Lets see what happens when we use Interaction.get_key'
      part << ''

      key = interaction.get_key

      part << "Ummmmm ... #{key.eql?('down')}"
      part << key.name.inspect
      part << key.inspect
      part << key.seq
      part << key.raw
      interaction.quit! if key.to_s == 'q'

      part << "#{key == :k}"
      part << "#{key == 'p'}"

      new_header ["Let's get the party started by TESTING THE FUCK OUT OF THIS SHIT"]
      new_footer ["wahahaha, #{key}"]

      @viewport.draw part, Size([0, 0]), @header, @footer
    end
  end

  def construct_search(interaction)
    enter_search_term interaction
    choose_options interaction
    # choose_sort_by interaction
  end

  def enter_search_term(interaction)
    term = ''
    draw_search_term_step term
    looping = true
    while looping
      key = interaction.get_key
      case key.to_s
      when 'control_m'
        looping = false
      when 'delete'
        term.slice!(-1)
      else
        term += key.to_s
      end
      draw_search_term_step term
    end
    @controller.term = term
  end

  def draw_search_term_step(term)
    part = Partial.new
    new_header ["Let's start with a search term", 'Type out a term, or leave it blank, then hit enter!']
    part << "Term: #{term}"
    new_footer ['Step 1: Search Term']
    draw part
  end

  def choose_options(interaction)
    options = []
    @controller.keys_of_options.each do |option|
      draw_choose_option_step("Option: do you want to #{option}? y/n", options)
      key = interaction.get_key
      if key == 'y'
        # allow tags
        @controller.add_option(option)
        options << "#{option} \xE2\x9C\x94"
      else
        options << "#{option} \xE2\x9D\x8C"
      end
    end
    draw_choose_option_step("Finished", options)
  end

  def draw_choose_option_step(body = nil, options = [])
    part = Partial.new
    new_header ['Next step is to choose the options you want from the following:']
    part << "#{body}".colorize(:blue)
    new_footer ['Step 2: Choose Options', options].flatten
    draw part
  end

  def choose_sort_by(_interaction)
    print_msg 'what would you like to sort by?'
    print_keys @controller.keys_of_sort_by
    print_msg 'enter the corresponding number (one only)'
    chosen = false
    until chosen
      input = gets.chomp
      input = input.to_i
      if input >= @controller.keys_of_sort_by.length || input < 0
        print_msg "#{input} does not correspond to a valid sort method"
      else
        chosen = true
        @controller.choose_sort_by @controller.keys_of_sort_by[input]
      end
    end
    print_msg 'sort by method chosen'
  end

  def welcome
    new_header ["The time is: #{Time.now}"]
    @welcomed = true
    part = Partial.new
    part << 'Welcome to the Steam Store CLI (unofficial)!'
    new_footer ["Screen size: #{Console.size} You pressed: #{@last_key}"]
    draw part
  end

  def navigate_results
    index_down if key.to_s == 'up'
    index_up if key.to_s == 'down'
    draw_arr_items
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
      part << if i == @index
                item.to_s.colorize(:blue)
              else
                item.to_s.colorize(:red)
              end
    end
    update_header_footer
    draw part
  end

  def draw(part)
    @viewport.draw part, Size([0, 0]), @header, @footer
  end

  def new_header(msgs_arr)
    @header = Partial.new
    msgs_arr.each { |msg| @header << msg.colorize(:red) }
  end

  def new_footer(msgs_arr)
    @footer = Partial.new
    msgs_arr.each { |msg| @footer << msg.colorize(:red) }
  end

  def update_header_footer
    new_header [
      'Viewing results from search',
      'Press Enter on a result to find more information about it'
    ]
    new_footer [
      "There are #{@arr.length} results, viewing #{@start + 1} - #{@end + 1}",
      @last_key.to_s,
      @index
    ]
  end
end
