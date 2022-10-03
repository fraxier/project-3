class StorePageController
  @base_url = 'https://store.steampowered.com/search/?'
  attr_writer :term

  def initialize
    initialize_options
    initialize_sort_by
    @chosen_options = []
    @chosen_sort_by = ''
    @term = ''
  end

  def initialize_options
    @options = {
      # 'term': 'term='
      # 'top sellers': 'filter=topsellers',
      # 'add tag(s)': 'tags=[tagid]',
      'hide free to play games': 'hidef2p=1',
      'show specials only': 'specials=1'
    }
  end

  def initialize_sort_by
    @sort_by = {
      'relevance': '',
      'release date (desc)': 'sort_by=Released_DESC',
      'name (asc)': 'sort_by=Name_ASC',
      'lowest price': 'sort_by=Price_ASC',
      'highest price': 'sort_by=Price_DESC',
      'user reviews (desc)': 'sort_by=Reviews_DESC',
      'steam deck compatibility review date (desc)': 'sort_by=DeckCompatDate_DESC'
    }
  end

  def generate_url(options, sort_bys)
    url = @base_url
    url = build_options url
    url = "#{url}&#{@chosen_sort_by}"
  end

  def build_options(url)
    if @term == '' && @chosen_options.length < 1
      url = "#{url}&filter=topsellers"
    else
      url = "#{url}&term=#{@term}" unless @term == ''
      @chosen_options.each { |option| url = "#{url}&#{option}" }
    end
    url
  end

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
  end

  def add_option(option)
    @chosen_options << @options[option]
  end

  def clear_options
    @chosen_options = []
  end

  def clear_sort_by
    @chosen_sort_by = ''
  end
end
