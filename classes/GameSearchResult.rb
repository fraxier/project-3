class GameSearchResult
  attr_accessor :name, :href, :price, :is_discounted, :discounted_from, :release_date, :sentiment

  def initialize(html)
    @href = html.attributes['href'].value
    @name = html.at_css('.search_name .title').text
    @is_discounted = !html.at_css('.search_price.discounted').nil?
    @release_date = html.at_css('.search_released').text
    parse_prices(html)
    review_summary = html.at_css('.search_review_summary')
    @sentiment = review_summary.attributes['data-tooltip-html'].value unless review_summary.nil?
    @sentiment = @sentiment.gsub('<br>', '') unless @sentiment.nil?
  end

  private

  def parse_prices(html)
    if @is_discounted
      @price = html.at_css('.search_price').children[3]
      @discounted_from = html.at_css('.search_price').children[1].text.strip
    else
      @price = html.at_css('.search_price')
      @discounted_from = nil
    end
    @price = @price.text.strip
  end

  def calculate_discount
    return '0%' if @is_discounted.false?

    "#{(@price / @discounted_from) * 100}%"
  end

end
