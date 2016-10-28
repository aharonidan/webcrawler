require './spec/spec_helper'

describe WebPage do
  let(:html) { <<-EOS
      <!DOCTYPE html>
      <html>
        <head>
          <title>Some Title</title>
        </head>
        <body>
          <p>Some content</p>
          <a href="/about">some link</a>
          <a href="http://different_domain.com/about">another link</a>
          <script src="http://script.com/foo.js"></script>
          <script src="/all.js"></script>
          <img src="http://image.com/baz.jpg"></img>
          <img src="//domain.com/bar.png"></img>
          <img src="/pisom.jpg"></img>
        </body>
      </html>
      EOS
  }
  let(:domain) { 'http://example.com' }
  let(:page) { WebPage.new(domain, domain) }

  describe '#initialize' do
    before(:each) do
      allow_any_instance_of(WebPage).to receive_message_chain(:open, :read).and_return(html)
    end

    it 'should initialize a web page' do
      expect(page.domain).to eq(domain)
    end

    it 'should fetch links' do
      expect(page.links).to include("#{domain}/about")
      expect(page.links).to include('http://different_domain.com/about')
    end

    it 'should fetch and format scripts' do
      expect(page.static_assets[:scripts]).to include('http://script.com/foo.js')
      expect(page.static_assets[:scripts]).to include("#{domain}/all.js")
    end

    it 'should fetch and format images' do
      expect(page.static_assets[:images]).to include('http://image.com/baz.jpg')
      expect(page.static_assets[:images]).to include("http://domain.com/bar.png")
      expect(page.static_assets[:images]).to include("#{domain}/pisom.jpg")
    end

    it 'should add url to sitemap xml' do
      doc = Nokogiri::XML::Builder.new { |xml| xml.url_set }.doc
      page.add_to_sitemap(doc)
      expect(doc.to_xml).to eq(<<-EOS)
<?xml version="1.0"?>
<url_set>
  <url>
    <loc>http://example.com</loc>
    <static_assets>
      <scripts>
        <script>http://script.com/foo.js</script>
        <script>http://example.com/all.js</script>
      </scripts>
      <images>
        <image>http://image.com/baz.jpg</image>
        <image>http://domain.com/bar.png</image>
        <image>http://example.com/pisom.jpg</image>
      </images>
    </static_assets>
  </url>
</url_set>
 EOS
    end
  end
end