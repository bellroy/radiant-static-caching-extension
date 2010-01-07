require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require 'fileutils'

#NOTE: This specs ensure that we don't cache 'private' and 'no-cache'
#TODO: Remove these specs once/if rack-contrib pulls out changes
describe Rack::ResponseCache do
  F = ::File

  def request(opts={}, &block)
    @response_headers = opts[:response_headers] || {}
    Rack::MockRequest.new(
      Rack::ResponseCache.new(@app, @cache)
    ).send(:get, opts[:path]||@path, opts[:headers]||{})
  end

  before do
    @cache = {}
    @disk_cache = F.join(F.dirname(__FILE__), 'response_cache_test_disk_cache')
    @value = ["rack-response-cache"]
    @path = '/path/to/blah.html'
    @app = lambda { |env| [200, {'Content-Type' => 'text/html'}.merge(@response_headers), @value]}
  end
  after do
    FileUtils.rm_rf(@disk_cache)
  end
  
  describe 'custom cache proc for radiant' do
    it 'should not cache requests with "no cache" cache control directive' do
      request(:response_headers => {"Cache-Control" => "no-cache"})
      @cache.should == {}
    end

    it 'should not cache requests with "private" cache control directive' do
      request(:response_headers => {"Cache-Control" => "private"})
      @cache.should == {}
    end
    
    it 'should cache requests with "public" cache control directive' do
      request(:response_headers => {"Cache-Control" => "public"})
      @cache.should == {@path=>@value}
    end
    
    it 'should cache requests with no cache control directive' do
      request(:response_headers => {})
      @cache.should == {@path=>@value}
    end
  end

  describe 'original proc functionality' do
    it "should unescape the path by default" do
      request(:path=>'/path%20with%20spaces')
      @cache.should == {'/path with spaces.html'=>@value}
      request(:path=>'/path%3chref%3e')
      @cache.should == {'/path with spaces.html'=>@value, '/path<href>.html'=>@value}
    end

    it "should cache html, css, and xml responses by default" do
      request(:path=>'/a')
      @cache.should == {'/a.html'=>@value}
      request(:path=>'/b', :response_headers=>{'Content-Type'=>'text/xml'})
      @cache.should == {'/a.html'=>@value, '/b.xml'=>@value}
      request(:path=>'/c', :response_headers=>{'Content-Type'=>'text/css'})
      @cache.should == {'/a.html'=>@value, '/b.xml'=>@value, '/c.css'=>@value}
    end

    it "should cache responses by default with the extension added if not already present" do
      request(:path=>'/a.html')
      @cache.should == {'/a.html'=>@value}
      request(:path=>'/b.xml', :response_headers=>{'Content-Type'=>'text/xml'})
      @cache.should == {'/a.html'=>@value, '/b.xml'=>@value}
      request(:path=>'/c.css', :response_headers=>{'Content-Type'=>'text/css'})
      @cache.should == {'/a.html'=>@value, '/b.xml'=>@value, '/c.css'=>@value}
    end

    it "should not delete existing unknown extensions" do
      request(:path=>'/d.seo', :response_headers=>{'Content-Type'=>'text/html'})
      @cache.should == {'/d.seo.html'=>@value}
    end

    it "should not cache when known extensions disagree with content type" do
      request(:path=>'/d.css', :response_headers=>{'Content-Type'=>'text/html'})
      @cache.should == {}
    end

    it "should cache html responses with empty basename to index.html by default" do
      request(:path=>'/')
      @cache.should == {'/index.html'=>@value}
      request(:path=>'/blah/')
      @cache.should == {'/index.html'=>@value, '/blah/index.html'=>@value}
      request(:path=>'/blah/2/')
      @cache.should == {'/index.html'=>@value, '/blah/index.html'=>@value, '/blah/2/index.html'=>@value}
    end
  end
end
