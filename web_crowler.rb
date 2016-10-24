#!/usr/bin/env ruby
require 'nokogiri'
require 'open-uri'
require 'pry'

class WebCrowler
  attr_reader :base_url, :to_crawl, :crawled, :indent

  def initialize(base_url)
    @base_url = base_url
    @to_crawl = [base_url]
    @crawled = []
  end

  def crawl(url)

    begin
      source = open(url).read
    rescue
      return
    ensure
      to_crawl.delete(url)
      crawled << url
    end

    puts "Visiting " + url
    doc = Nokogiri::HTML.parse source
    links = doc.css('a').map { |link| link['href']}

    links.uniq! if links
    links.compact! if links

    links.each do |link|
      link = modify_link_to_url(link)
      if link && !crawled.include?(link) && !to_crawl.include?(link)
        to_crawl << link
      end
    end
  end

  def modify_link_to_url(link)
    if link.include? base_url
      result = link
    elsif link.match(/^\/.*\/$/)
      link[0] = ''
      result = base_url + link
    end
    result
  end

end

crawler = WebCrowler.new('https://gocardless.com/')

i = 0
while crawler.to_crawl.any? && i < 50
  crawler.crawl(crawler.to_crawl.first)
  i = i+1
end

puts crawler.crawled


