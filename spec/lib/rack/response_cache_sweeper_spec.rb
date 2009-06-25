require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Rack::ResponseCacheSweeper do  
  before do
    @cache = '/path/to/blah'
    @app = lambda { |env| [200, {}, []]} 
  end
  
  def request
    Rack::MockRequest.new(Rack::ResponseCacheSweeper.new(@app, @cache)).request(@meth)
  end
  
  describe "when processing different HTTP verbs: " do
    after do
      request
    end
  
    %w(GET HEAD).each do |meth|
      it "shouldn't do anything for #{meth} requests" do
        @meth = meth
        FileUtils.should_not_receive(:rm_rf)
      end
    end
  
    %w(POST DELETE PUT).each do |meth|
      it "should remove the cache directory for #{meth}" do
        @meth = meth
        FileUtils.should_receive(:rm_rf).with(@cache)
      end
    end
  end

  describe 'app response' do
    before do
      @app.stub!(:call).and_return [@status = 200, @headers = {}, @body = ""]
      @response = Rack::MockResponse.new(@status, @headers, @body)
    end
    
    it "should not modify the status" do
      request.status.should == @status
    end
    
    it "should not modify the headers" do
      request.headers.should == @headers
    end
    
    it "should not modify the body" do
      request.body.should == @body
    end
  end
  
  it "shouldn't modify the environment" do
    FileUtils.stub!(:rm_rf)
    @foo = mock("foo", :[] => nil)
    r = Rack::ResponseCacheSweeper.new(@app, @cache)
    @app.should_receive(:call).with @foo
    r.call(@foo)
  end
  
end