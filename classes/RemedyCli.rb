class RemedyCli
  attr_accessor :header, :footer

  include Remedy

  def initialize
    @viewport = Viewport.new
    @controller = StorePageController.new

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
    welcome_menu interaction
    interaction.loop do |key|
      @last_key = key
      interaction.quit! if key == 'q'
      construct_search interaction
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
  
  # TODO create the actual menu logic
  def welcome_menu(interaction)
    new_header ["The time is: #{Time.now}"]
    
    part = Partial.new
    part << 'Welcome to the Steam Store CLI (unofficial)!'
    new_footer ["Screen size: #{Console.size} You pressed: #{@last_key}"]
    draw part
  end

  def construct_search(interaction)
    @query = []
    enter_search_term interaction
    choose_options interaction
    choose_sort_by interaction
    confirm_search interaction
  end

  def update_current_query(msg)
    @query << msg
  end

  def generate_query_string
    message = @query.reduce('') { |msg, sub| msg.concat(sub, "\n") }
  end

  def enter_search_term(interaction)
    term = ''
    draw_search_term_step(term, false)
    looping = true
    while looping
      key = interaction.get_key
      case key.to_s
      when 'control_m'
        looping = false
      when 'delete'
        term.slice!(-1)
      when 'space'
        term += ' '
      else
        term += key.to_s
      end
      draw_search_term_step(term, false)
    end
    @controller.term = term
    draw_search_term_step(term, true)
  end

  def draw_search_term_step(term, done)
    part = Partial.new
    new_header ["Let's start with a search term", 'Type out a term, or leave it blank, then hit enter!']
    part << "Term: #{term}"
    update_current_query "Search Term: #{term || 'None'}" if done
    new_footer ['Step 1: Search Term', generate_query_string]
    draw part
  end

  def choose_options(interaction)
    cur_option = ''
    @controller.keys_of_options.each do |option|
      draw_choose_option_step("Option: do you want to #{option}? y/n", cur_option)
      key = interaction.get_key
      if key == 'y'
        # allow tags
        @controller.add_option(option)
        cur_option = "#{option} \xE2\x9C\x94"
      else
        cur_option = "#{option} \xE2\x9D\x8C"
      end
    end
    draw_choose_option_step('Finished', cur_option)
  end

  def draw_choose_option_step(body, cur_option)
    part = Partial.new
    new_header ['Next step is to choose the options you want from the following:']
    part << body.to_s.colorize(:blue)
    update_current_query cur_option unless cur_option == ''
    new_footer ['Step 2: Choose options', generate_query_string]
    draw part
  end

  def choose_sort_by(interaction)
    draw_choose_sort_by_step 'Enter the number that corresponds to the sort method you want'
    key = interaction.get_key

    until [1..@controller.keys_of_sort_by.length].include? key.to_s.to_i
      key = interaction.get_key
      draw_choose_sort_by_step "#{key} does not correspond to a valid sort method"
    end
    sort_by = @controller.keys_of_sort_by[key.to_s.to_i]
    @controller.choose_sort_by sort_by
    update_current_query "Sorting By: #{sort_by}"
  end

  def draw_choose_sort_by_step(msg)
    new_header ['What would you like to sort by?', @controller.keys_of_sort_by].flatten
    part = Partial.new
    part << msg
    new_footer ['Step 3: Choose sort method', generate_query_string]
    draw part
  end

  def confirm_search(interaction)
    new_header ["Go ahead with this search?"]
    part = Partial.new
    part << 'Press enter to confirm or C to cancel'
    new_footer [generate_query_string]
    draw part
    key = interaction.get_key
    case key.to_s.downcase
    when 'control_m'
      do_search
    when 'c'
      
    end
  end

  def do_search
    url = @controller.generate_url
    @search_results = Scraper.scrape_page_for_games url
    navigate_results
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
      game = @search_results[i]
      part << if i == @index
                game.to_s.colorize(:blue)
              else
                game.to_s.colorize(:red)
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
