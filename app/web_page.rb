require 'nokogiri'
require 'open-uri'

class WebPage

  attr_reader :url, :domain,:document, :links, :static_assets

  def initialize(url, domain)
    @url, @domain = url, domain
    @document = parse_document
    @links = fetch_links
    @static_assets = fetch_static_assets
  end

  def parse_document
    source = open(url).read
    Nokogiri::HTML.parse source
  end

  def fetch_links
    find_in_document('a', 'href')
  end

  def fetch_static_assets
    scripts = find_in_document('script', 'src')
    images = find_in_document('img', 'src')
    { scripts: scripts, images: images }
  end

  def find_in_document(selector, attribute)
    elements = document.css(selector).map { |element| element[attribute] }
    elements.map! { |link| format(link) }
    elements.compact.uniq
  end

  def format(link)
    if invalid?(link)
      nil
    elsif link.match(/^\/\/.*/)
        'http:' + link
    elsif link.match(/^\/.*/)
      domain.chomp('/') + link
    else
      link
    end
  end

  def invalid?(link)
    link.nil? || link.empty? || link.include?('email-protection')
  end

  def add_to_sitemap(doc)
    url_node = Nokogiri::XML::Node.new('url', doc)

    loc_node = Nokogiri::XML::Node.new('loc', doc)
    loc_node.content = url
    url_node << loc_node

    assets_node = Nokogiri::XML::Node.new('static_assets', doc)
    assets_node << populate_nodes(static_assets[:scripts], 'script', doc)
    assets_node << populate_nodes(static_assets[:images], 'image', doc)

    url_node << assets_node
    doc.root << url_node
  end

  def populate_nodes(links, tag, doc)
    parent_node = Nokogiri::XML::Node.new("#{tag}s", doc)
    links.each do |link|
      node = Nokogiri::XML::Node.new(tag, doc)
      node.content = link
      parent_node << node
    end
    parent_node
  end
end