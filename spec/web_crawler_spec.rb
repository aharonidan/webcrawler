require './spec/spec_helper'

describe WebCrawler do

  let(:domain) { 'http://example.com/' }
  let(:crawler) { WebCrawler.new(domain) }

  describe '#initialize' do
    it 'should initialize a web crawler' do
      expect(crawler.domain).to eq(domain)
    end

    it 'should add url to to_visit list' do
      expect(crawler.to_visit).to eq([domain])
    end

    it 'should initialize a sitemap xml' do
      expect(crawler.sitemap.to_xml).to eq("<?xml version=\"1.0\"?>\n<url_set/>\n")
    end
  end

  describe '#visit_page' do
    before(:each) do
      html_content = <<-EOS
        <!DOCTYPE html>
        <html>
          <head>
            <title>Some Title</title>
          </head>
          <body>
            Some content
            <a href="/about">some link</a>
            <a href="www.different_domain.com/about">another link</a>
            <script src="www.script.com"></script>
            <img src="www.image.com"></img>
          </body>
        </html>
        EOS
      allow_any_instance_of(WebPage).to receive_message_chain(:open, :read).and_return(html_content)
      to_visit = crawler.to_visit.first
      crawler.visit_page(to_visit)
    end

    it 'should visit page' do
      expect(crawler.visited[domain]).to be_truthy
    end

    it 'should add links to visit' do
      expect(crawler.to_visit).to eq(["#{domain}about"])
    end

    it 'should not add links from a different domain' do
      expect(crawler.to_visit).not_to include('www.different_domain.com/about')
    end

    it 'should start crawling' do
      crawler.crawl
      expect(crawler.visited["#{domain}about"]).to be_truthy
    end
  end
end