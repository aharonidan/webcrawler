require './app/web_page'
require 'pry'

class WebCrawler

  attr_reader :domain, :to_visit, :visited, :pages, :sitemap

  def initialize(domain, page_limit)
    @domain = domain
    @to_visit, @visited = [], {}
    @sitemap = initialize_xml
    visit_page(domain)
  end

  def visit_page(url)
    begin
      page = WebPage.new(url, domain)
      page.add_to_sitemap(sitemap)
      visited[url] = page
      add_links_to_visit(page)

    rescue => e
      puts e.message
    ensure
      to_visit.delete(url)
    end
  end

  def initialize_xml
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.url_set
    end
    builder.doc
  end

  def add_links_to_visit(page)
    links_to_add = page.links.reject do |link|
      to_visit.include?(link) || visited[link] || !link.include?(stripped_domain)
    end
    to_visit.push(*links_to_add)
  end

  def stripped_domain
    @stripped_domain ||= domain.gsub('http://','').gsub('https://','').gsub('www','')
  end

  def crawl
    while to_visit.any?
      visit_page(to_visit.first)
    end
  end
end





