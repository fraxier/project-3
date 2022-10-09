class RemedyCli
  attr_accessor :header, :footer, :search_results, :chomping_term

  include Remedy

  def initialize
    @viewport = Viewport.new
    @search_results = []
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
    searcher = Searcher.new self
    welcome_screen # draw it once here to show something to user before needing keyboard input
    @interaction.loop do |key|
      show_quit_screen if key == 'q'
      searcher.construct_search if key == 's'
      navigate_results if key == 'r'
      welcome_screen # draw it again once search is complete
    end
  end

  def welcome_screen
    quick_draw(
      msg: [
        'Welcome to the Steam Store CLI (unofficial)!',
        'Perform a search: Press S',
        'Navigate past results: Press R',
        'Exit program: Press Q'
      ],
      header_msg: "The time is: #{Time.now}",
      footer_msg: [
        "Screen size: #{Console.size}",
        "Search Results: #{@search_results.length} results"
      ]
    )
  end

  def navigate_results
    if @search_results.empty?
      quick_draw(msg:
      [
        'There are no previous search results to navigate through'.colorize(:red),
        'Please press any key to continue...'.colorize(:yellow)
      ])
      chomp_key
      return
    end
    navigator = ResultsNavigator.new self
    navigator.navigate
  end

  def chomp_key
    key = @interaction.get_key
    show_quit_screen if key == :q && !chomping_term
    key
  end

  def show_quit_screen
    last_header = @header.lines.dup
    last_footer = @footer.lines.dup
    last_part = @last_part.lines.dup

    quick_draw(msg: 'Are you sure you want to quit? y/n'.colorize(:red))
    key = @interaction.get_key
    if key == 'y'
      ANSI.cursor.home!
      ANSI.command.clear_down!
      ANSI.cursor.show!
      puts 'See ya later aligator!'
      exit
    end
    quick_draw(header_msg: last_header, msg: last_part, footer_msg: last_footer)
  end

  def update_arr_draw(start, last, index, part)
    new_header [
      'Viewing results from search',
      'Press Enter on a result to find more information about it'
    ]
    new_footer [
      "There are #{@search_results.length} results, viewing #{start + 1} - #{last + 1}",
      "Current index: #{index}",
      'Press Q to quit'.colorize(:red)
    ]
    draw part
  end

  def draw(part)
    @last_part = part
    @viewport.draw part, Size([0, 0]), @header, @footer
  end

  def draw_game_page(game)
    quick_draw(
      header_msg: "Extra details for #{game.name}",
      footer_msg: 'Press B to go back to the results page',
      msg: [
        game.desc.to_s.colorize(:blue),
        "Release Date: #{game.release_date}",
        "Reviews: #{game.sentiment}",
        'Developed by:',
        game.print_devs.map { |dev| dev.colorize(:blue) }
      ]
    )
    chomp_key
  end

  def quick_draw(msg:, header_msg: '', footer_msg: '')
    new_header [header_msg].flatten unless header_msg == ''
    new_footer [footer_msg].flatten unless footer_msg == ''
    draw new_part([msg].flatten)
  end

  private

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
end
