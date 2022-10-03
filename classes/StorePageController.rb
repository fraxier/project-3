class StorePageController
  @base_url = 'https://store.steampowered.com/search/?'
  attr_reader :term

  def initialize
    initialize_options
    initialize_sort_by
    @chosen_options = []
    @chosen_sort_by = ''
    @term = ''
  end

  def initialize_options
    @options = {
      'top sellers': 'filter=topsellers',
      'hide f2p': 'hidef2p=1',
      'show specials only': 'specials=1',
      '[tag]': 'tags=[tagid]'
    }
  end

  def initialize_sort_by
    @sort_by = {
      'relevance': '',
      'release date': 'sort_by=Released_DESC',
      'name ascending': 'sort_by=Name_ASC',
      'lowest price': 'sort_by=Price_ASC',
      'highest price': 'sort_by=Price_DESC',
      'user reviews': 'sort_by=Reviews_DESC',
      'steam deck compatibility review date': 'sort_by=DeckCompatDate_DESC'
    }
  end

  def generate_url(options, sort_bys); end

  def keys_of_options
    @options.keys
  end

  def keys_of_sort_by
    @sort_by.keys
  end

  def term?
    @term
  end

  def choose_sort_by(sort)
    @chosen_sort_by = @sort_by[sort]
    CLI.print_msg("sorting by #{sort}")
  end

  def add_option(option)
    @chosen_options << @options[option]
    CLI.print_msg("added #{option} to search options")
  end

  def clear_options
    @chosen_options = []
  end

  def clear_sort_by
    @chosen_sort_by = ''
  end
end
