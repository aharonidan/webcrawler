require './app/web_crawler'
require 'pry'

url = ARGV[0] || 'https://gocardless.com/'
output_file = ARGV[1] || 'sitemap.xml'

puts 'Started crawling! hold tight..'
puts "Input url is #{url}"

crawler = WebCrawler.new(url)
crawler.crawl

File.open(output_file, 'w') do |file|
  file.print crawler.xml.to_xml
end