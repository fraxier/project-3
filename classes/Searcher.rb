
class Searcher

  def initialize(cli)
    @cli = cli
    @controller = StorePageController.new
  end

  def construct_search
    @query = []
    top_seller = choose_options
    enter_search_term unless top_seller
    choose_sort_by
    confirm_search
  end

  def update_current_query(msg)
    @query << msg
  end

  def generate_query_string
    @query.reduce('') { |message, sub| message.concat(sub, "\n") }
  end

  def enter_search_term
    term = ''
    draw_search_term_step(term, false)
    looping = true
    while looping
      key = @cli.chomp_key
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
    update_current_query "Search Term: #{term == '' ? 'None' : term}" if done

    @cli.quick_draw(
      msg: "Term: #{term}",
      header_msg: ["Let's start with a search term", 'Type out a term, or leave it blank, then hit enter!'],
      footer_msg: ['Step: Search Term', generate_query_string]
    )
  end

  def choose_options
    cur_option = ''
    count = 0
    top_seller = false
    @controller.keys_of_options.each do |option|
      draw_choose_option_step("Option: do you want to #{option}? y/n", cur_option)
      done = false
      until done
        key = @cli.chomp_key
        if key == 'y'
          @controller.add_option(option)
          cur_option = "#{option} \xE2\x9C\x94"
          done = true
          top_seller = true if count.zero?
        elsif key == 'n'
          cur_option = "#{option} \xE2\x9D\x8C"
          done = true
          count += 1
        end
      end
      break if top_seller
    end
    draw_choose_option_step('Finished', cur_option)
    top_seller
  end

  def draw_choose_option_step(body, cur_option)
    update_current_query cur_option unless cur_option == ''

    @cli.quick_draw(
      header_msg: 'Next step is to choose the options you want from the following',
      msg: body.to_s.colorize(:blue),
      footer_msg: ['Step: Choose options', generate_query_string]
    )
  end

  def choose_sort_by
    draw_choose_sort_by_step 'Enter the number that corresponds to the sort method you want'
    key = @cli.chomp_key

    until (1..@controller.keys_of_sort_by.length).include? key.seq.to_s.to_i
      draw_choose_sort_by_step "#{key.seq} does not correspond to a valid sort method"
      key = @cli.chomp_key
    end
    sort_by = @controller.keys_of_sort_by[key.seq.to_s.to_i - 1]
    @controller.choose_sort_by sort_by
    update_current_query "Sorting By: #{sort_by}"
  end

  def draw_choose_sort_by_step(msg)
    @cli.quick_draw(
      msg: [msg, @controller.keys_of_sort_by_with_index_and_string.map { |key| key.colorize(:blue) }],
      header_msg: 'What would you like to sort by?',
      footer_msg: ['Step: Choose sort method', generate_query_string]
    )
  end

  def confirm_search
    draw_confirm_search 'Press enter to confirm or C to cancel'
    looping = true
    go = false
    while looping
      key = @cli.chomp_key
      if key.to_s == 'control_m'
        looping = false
        go = true
      elsif key == 'c'
        looping = false
      else
        draw_confirm_search "Please press enter to confirm or C to cancel. You pressed #{key}"
      end
    end
    do_search if go
  end

  def draw_confirm_search(msg)
    @cli.quick_draw(
      header_msg: 'Go ahead with this search?',
      footer_msg: generate_query_string,
      msg: msg
    )
  end

  def do_search
    url = @controller.generate_url
    @cli.search_results = SteamStoreScraper.scrape_page_for_games url
    @cli.navigate_results
  end
end