class Tag
  attr_accessor :name, :id

  @@tags = []
  @@steam_tags_url = 'https://store.steampowered.com/tag/browse/#global_492'

  def initialize(name, id)
    @name = name
    @id = id
    @@tags << self
  end

  def self.retrieve_steam_tags
    doc = Nokogiri::HTML5(URI.open(steam_tags_url))
    items = doc.css('.tag_browse_tag')

    items.each do |item|
      Tag.new item.text, item.attributes['data-tagid'].value unless item.attributes['data-tagid'].nil?
    end
  end
end
