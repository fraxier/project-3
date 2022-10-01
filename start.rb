require_relative './config/environment'

steam_url = 'https://store.steampowered.com/search/?filter=topsellers'
steam_tags_url = 'https://store.steampowered.com/tag/browse/'
# 'tag_browse_tag' -data-tag-id

doc = Nokogiri::HTML5(URI.open(steam_tags_url))

# search_results = doc.css('#search_resultsRows')

# links = search_results.css('a')

# games = links.map do |result|
#   GameSearchResult.new result
# end

options = {
  'top sellers': 'filter=topsellers',
  'hide f2p': 'hidef2p=1',
  'show specials only': 'specials=1',
  '[tag]': 'tags=[tagid]'
}

sort_by = {
  'relevance': '',
  'release date': 'sort_by=Released_DESC',
  'name ascending': 'sort_by=Name_ASC',
  'lowest price': 'sort_by=Price_ASC',
  'highest price': 'sort_by=Price_DESC',
  'user reviews': 'sort_by=Reviews_DESC',
  'steam deck compatibility review date': 'sort_by=DeckCompatDate_DESC'
}

binding.pry
