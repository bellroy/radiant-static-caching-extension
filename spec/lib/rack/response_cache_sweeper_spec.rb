require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Rack::ResponseCacheSweeper do
  before do
    @cache = '/path/to/blah'
    @app = lambda { |env| [200, {}, []]}
    FileUtils.stub! :touch
    FileUtils.stub! :rm_rf
  end

  def request
    Rack::MockRequest.new(Rack::ResponseCacheSweeper.new(@app, @cache)).request(@meth)
  end

  describe "when processing different HTTP verbs: " do
    after do
      request
    end

    %w(GET HEAD).each do |meth|
      describe "for #{meth} requests" do
        before do
          @meth = meth
        end

        it "shouldn't blow away the cache" do
          FileUtils.should_not_receive :rm_rf
        end

        it "shouldn't touch last_edit" do
          FileUtils.should_not_receive :touch
        end
      end
    end

    %w(POST DELETE PUT).each do |meth|
      describe "for #{meth} requests" do
        before do
          @meth = meth

        end

        it "should remove the contents of the cache directory" do
          FileUtils.should_receive(:rm_rf).with Dir.glob(File.join(@cache, '*'))
        end

        it "should remove last_edit and last_spider_attempt from the cache directory" do
          FileUtils.should_receive(:rm_rf).with File.join(@cache, ".last_edit")
          FileUtils.should_receive(:rm_rf).with File.join(@cache, ".last_spider_attempt")
        end

        it "should touch last_edit" do
          FileUtils.should_receive(:touch).with File.join(@cache, '.last_edit')
        end
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
    @foo = mock("foo", :[] => nil)
    r = Rack::ResponseCacheSweeper.new(@app, @cache)
    @app.should_receive(:call).with @foo
    r.call(@foo)
  end

end