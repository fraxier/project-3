# Handles displaying and prompting information to and from user
class Cli
  attr_reader :commands, :looping, :msg_prompt
  attr_accessor :controller

  def initialize
    @looping = true
    @controller = StorePageController.new
    @msg_prompt = 'hello! view commands with list-commands'
    String.disable_colorization = false
    @welcomed = false
  end

  def begin_loop
    until @looping == false

      welcome unless @welcomed
      construct_search
      search
      use_results

    end
  end

  def use_results
    looping = true
    user_input = Interaction.new
    print_msg 'press ctrl+q to stop using search results'
    user_input.loop do |key|
      
    end
  end

  def construct_search
    enter_search_term
    choose_options
    choose_sort_by
  end

  def search
    url = @controller.generate_url
    @games = Scraper.scrape_page_for_games url

    print_results
  end

  def print_results(num = 0)
    num = @games.length if num < 1
    @games.slice(0, num).each do |result|
      puts "#{result.name} - #{result.price} - #{result.sentiment}"
    end

  end

  def enter_search_term
    input = gets.chomp
    return nil if input.empty?
    @controller.term = input
  end

  def choose_options
    @controller.keys_of_options.each do |key|
      print_msg "do you want to #{key}? y/n"
      input = gets.chomp
      if ['yes', 'y'].include? input
        if key == 'add tag(s)'
          add_tags
        else
          @controller.add_option key
        end
      else
        print_msg "skipped #{key}"
      end
    end
    print_msg 'options chosen'
  end

  def choose_sort_by
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
    print_msg 'Welcome to the Steam Store Game CLI (unofficial)!'
    @welcomed = true
  end

  def self.print_keys(items)
    items.each_with_index { |item, i| puts "#{i} => '#{item.to_s.colorize(:blue)}' " }
  end

  def self.print_msg(msg)
    puts msg.colorize(:red)
  end
end
