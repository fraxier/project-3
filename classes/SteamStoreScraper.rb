
class SteamStoreScraper

  def self.scrape_page_for_games(url)
    binding.pry
    doc = Nokogiri::HTML5(URI.open(url))

    search_results = doc.css('#search_resultsRows')

    links = search_results.css('a')

    games = links.map do |result|
      GameSearchResult.new result
    end
  end

end