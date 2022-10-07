# frozen
class SteamStoreScraper
  def self.scrape_page_for_games(url)
    doc = Nokogiri::HTML5(URI.open(url))

    search_results = doc.css('#search_resultsRows')

    links = search_results.css('a')

    links.map do |result|
      GameSearchResult.new result
    end
  end

  def self.scrape_game_page(game)
    doc = Nokogiri::HTML5(URI.open(game.href))

    right_col = doc.at_css('#game_highlights .rightcol')
    game.desc = right_col.at_css('.game_description_snippet')
    game.desc = game.desc.text.strip unless game.desc.nil?
    developers = right_col.css('#developers_list a')
    game.devs = developers.map do |dev|
      developer = Developer.new(link: dev.attributes['href'], name: dev.text)
    end
    game
    # rows = right_col.css('.dev_row')
    # pub = rows[1].at_css('.summary.column a')
    # publisher = {}
    # publisher.link = pub.attribute['href']
    # publisher.name = pub.text
  end
end
