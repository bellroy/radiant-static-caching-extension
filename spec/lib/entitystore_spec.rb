require File.dirname(__FILE__) + '/../spec_helper'
require 'trike/cache/entitystore'

describe Trike::Cache::EntityStore do

  before do
    {File => [:exists?, :unlink, :open], FileUtils => [:mv, :mkdir_p]}.each do |klass, methods|
      methods.each { |m| klass.stub!(m)}
    end

    @root_path = "/root/path"
    @store = Trike::Cache::EntityStore.new(@root_path)
  end

  describe "storing a page" do

    it "should use the path of the page as the digest" do
      path = "a/path"
      @store.stub!(:slurp)
      @store.stub!(:generate_key)
      @store.stub!(:storage_path).and_return(@root_path+"/"+path)
      FileUtils.should_receive(:mv).with(anything, "#{@root_path}/#{path}")
      @store.write("body", "text/plain", "http://www.example.com/path/to/file?query=string")
    end

    it "writes the content of the page to a file" do
      cache_file = StringIO.new
      File.stub!(:open).and_yield(cache_file)

      body = "Some body text"
      @store.write(body, "text/html", "http://www.example.com/path/to/file")
      cache_file.string.should == body
    end

  end

  describe "streaming the body" do

    it "should return the total content length" do
      body = "The body"
      @store.slurp(body) { |x| x }.should == body.length
    end

  end

  describe "generating keys" do

    before do
      @store = Trike::Cache::EntityStore.new("/root/path")
    end
    
    it "adds index.html when accessing the root of the site" do
      @store.generate_key("text/html", "http://www.example.com/").should == "/index.html"
    end

    it "includes the query string" do
      @store.generate_key("text/html", "http://www.example.com/path/to/file?query=string").should == "/path/to/file?query=string.html"
    end

    it "adds a html extension when it is missing and the content type is html" do
      @store.generate_key("text/html", "http://www.example.com/path/to/page").should == "/path/to/page.html"
    end

    it "should not add an extension when it is missing and the content type is not html " do
      @store.generate_key("text/plain", "http://www.example.com/path/to/page").should == "/path/to/page"
    end

    it "adds an xml extension when it is missing and the content type is xml" do
      pending 'Future enhancement'
      @store.generate_key("text/xml", "http://www.example.com/path/to/page").should == "/path/to/page.xml"
    end

    it "should not add an extension when one is already present" do
      @store.generate_key("text/css", "http://www.example.com/path/to/main.css?").should == "/path/to/main.css"
    end

    it "copies the extension if there is a query string" do
      @store.generate_key("text/html", "http://www.example.com/path/to/index.html?stuff").should == "/path/to/index.html?stuff.html"
    end

    it "handles writes the empty path to index" do
      @store.generate_key("text/html", "http://www.example.com/path/to/").should == "/path/to/index.html"      
    end

  end

  it 'aliases body_path to storage_path' do
    @store.method(:body_path).should == @store.method(:storage_path)
  end

end
