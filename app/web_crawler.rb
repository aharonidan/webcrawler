require './app/web_page'

class WebCrawler

  attr_reader :domain, :stripped_domain, :to_visit, :visited, :sitemap

  def initialize(domain)
    @domain = domain
    @stripped_domain = strip_domain
    @to_visit = [domain]
    @visited = {}
    @sitemap = initialize_xml
  end

  def visit_page(url)
    begin
      page = WebPage.new(url, domain)
      puts "Visiting #{url}"
      page.add_to_sitemap(sitemap)
      visited[url] = page
      add_links_to_visit(page)

    rescue # catch if failed to load page
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
    # add only links that we did not visit yet and in our domain
    links_to_add = page.links.reject do |link|
      to_visit.include?(link) || visited[link] || !link.include?(stripped_domain)
    end
    to_visit.push(*links_to_add)
  end

  # take 'http' and 'www' off the url
  def strip_domain
    result = domain
    ['http://', 'https://','www'].each do |str|
      result = result.gsub(str,'')
    end
    result
  end

  def crawl
    while to_visit.any?
      visit_page(to_visit.first)
    end
  end
end