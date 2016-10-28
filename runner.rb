require './app/web_crawler'

url = ARGV[0] || 'https://gocardless.com/'
output_file = ARGV[1] || 'sitemap.xml'

puts 'Started crawling! hold tight..'
puts "Input url is #{url}"

crawler = WebCrawler.new(url)
crawler.crawl

File.open(output_file, 'w') do |file|
  file.print crawler.sitemap.to_xml
end

puts "Done! your output is waiting in #{output_file}"