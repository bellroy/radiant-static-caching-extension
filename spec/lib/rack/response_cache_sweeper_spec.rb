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
  
  it "should return whatever the app returns" do
    response = [status = 200, headers = {}, body = ""]
    response_obj = Rack::MockResponse.new(status, headers, body)
    @app.stub!(:call).and_return response
    request.status.should == response_obj.status
    request.headers.should == response_obj.headers
    request.body.should == response_obj.body
  end
  
  it "shouldn't modify the environment" do
    FileUtils.stub!(:rm_rf)
    @foo = mock("foo", :[] => nil)
    r = Rack::ResponseCacheSweeper.new(@app, @cache)
    @app.should_receive(:call).with @foo
    r.call(@foo)
  end
  
end