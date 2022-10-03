class GameSearchResult
  attr_accessor :name, :href, :price, :is_discounted, :discounted_from, :release_date, :sentiment

  def initialize(html)
    @href = html.attributes['href'].value
    @name = html.at_css('.search_name .title').text
    @is_discounted = !html.at_css('.search_price.discounted').nil?
    @release_date = html.at_css('.search_released').text
    parse_prices html
    prase_sentiment html
  end
  
  private
  
  def parse_sentiment(html)
    review_summary = html.at_css('.search_review_summary')
    return if review_summary.nil?
    
    @sentiment = review_summary.attributes['data-tooltip-html'].value
    match = @sentiment.match(/^[a-zA-Z ]*/)
    @sentiment["#{match}"] = "#{match} - "
    @sentiment = @sentiment.gsub('<br>', '') unless @sentiment.nil?
  end

  def parse_prices(html)
    node = html.at_css('.search_price')
    
    if node.nil?
      @price = 'Not found'
      @discounted_from = 'N/A'
    end

    if @is_discounted
      @price = node.children[3]
      @discounted_from = node.children[1].text.strip
    else
      @price = node
      @discounted_from = nil
    end
    @price = @price.text.strip
  end

  def calculate_discount
    return '0%' if @is_discounted.false?

    "#{(@price / @discounted_from) * 100}%"
  end

end
