class ResultsNavigator
  def initialize(cli)
    @cli = cli
    @games = cli.search_results

    @index = 0
    @max_num_viewable = 25
    @start = 0
    @last = if @max_num_viewable > @games.length - 1
              @games.length - 1
            else
              @max_num_viewable - 1
            end
  end

  def navigate
    looping = true
    while looping
      draw_arr_items
      key = @cli.chomp_key
      index_down if key.to_s == 'up'
      index_up if key.to_s == 'down'
      enter_game if key.to_s == 'control_m'
      looping = false if key == :b
    end
  end

  def enter_game
    game = @games[@index]
    good = SteamStoreScraper.scrape_game_page game
    if good.nil?
      @cli.quick_draw(
        header_msg: 'Error - Unable to load page',
        msg: 'Possible age check required to load page',
        footer_msg: 'Press any key to go back to page results...'
      )
      @cli.chomp_key
    else
      navigate_game_page(game)
    end
  end

  def navigate_game_page(game)
    looping = true
    while looping
      @cli.draw_game_page game
      key = @cli.chomp_key
      looping = false if key == 'b'
      # save_game if key == 's'
    end
  end

  def index_up
    if @index < @games.length - 1
      @index += 1
      if @index == @last + 1 && @last < @games.length - 1
        @last += 1
        @start += 1
      end
    end
  end

  def index_down
    if @index.positive?
      @index -= 1
      if @index == @start && @start.positive?
        @last -= 1
        @start -= 1
      end
    end
  end

  # rubocop:disable Style/For
  def draw_arr_items
    part = Partial.new
    for i in @start..@last do
      result = @games[i]
      part << if i == @index
                result.pretty_string.colorize(:blue)
              else
                result.pretty_string.colorize(:red)
              end
    end
    @cli.update_arr_draw(@start, @last, @index, part)
    @cli.draw part
  end
  # rubocop:enable Style/For
end
