# Handles displaying and prompting information to and from user
class CLI
  attr_reader :commands, :looping, :msg_prompt

  def initialize
    @commands = %w[what list-commands quit list-sorts sort-by list-options add-options clear-options term term? search]
    @looping = true
    @controller = StorePageController.new
    @msg_prompt = 'hello! view commands with list-commands'
    String.disable_colorization = false
  end

  def begin_loop
    until @looping == false

      puts @msg_prompt.colorize(:red)
      parse_input gets.chomp

    end
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity
  def parse_input(command)
    case command
    when 'what'
      what
    when 'list-commands'
      list_commands
    when 'quit'
      puts 'Quitting program, bye bye!'.colorize(:red)
      @looping = false
    when 'list-sorts'
      list_sort_by
    when 'sort-by'
      puts 'Choose a way to sort search results'.colorize(:red)
      listen_for_sort_by
    when 'list-options'
      list_options
    when 'add-options'
      listen_for_options
    when 'clear-options'
      clear_options
    when 'clear-sort'
      clear_sort_by
    when 'term'
      listen_for_term
    when 'term?'
      print_term
    when 'search'
      search
    end
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/CyclomaticComplexity

  def what
    print_msg 'This is a CLI that scrapes the Steam store search page!'
    print_msg "Use the commands to construct a search query, a search with default parameters creates a search for Steam's top sellers"
    print_msg 'You can choose to add any number of "options", a "sort-by" method and a search term'
  end

  # PRINT COMMANDS TO USER
  def list_commands
    print_list @commands
  end

  def list_sort_by
    print_list @controller.keys_of_sort_by
  end

  def list_options
    print_list @controller.keys_of_options
  end

  def print_list(items)
    items.each { |item| print "'#{item.to_s.colorize(:blue)}' " }
    puts
  end

  # rubocop:disable Metrics/MethodLength
  def listen_for_sort_by
    listening = true
    while listening
      binding.pry
      sort = gets.chomp
      if @controller.keys_of_sort_by.include? sort.to_sym
        @controller.choose_sort_by sort
        listening = false
      elsif sort == 'list-sorts'
        list_sort_by
      else
        puts "#{sort} is not a valid sort method".colorize(:red)
        listening = false
      end
    end
  end
  # rubocop:enable Metrics/MethodLength

  def listen_for_options
    listening = true
    while listening
      option = gets.chomp
      if @controller.keys_of_options.include? option.to_sym
        @controller.add_option option
      elsif option == 'done'
        listening = false
      end
    end
  end

  def clear_options
    @controller.clear_options
  end

  def clear_sort_by
    @controller.clear_options
  end

  def listen_for_term
    input = gets.chomp
    CLI.term = input
  end

  def print_term
    print_msg CLI.term?
  end

  def search
    # TODO
  end

  def self.print_msg(msg)
    puts msg.colorize(:red)
  end
end
