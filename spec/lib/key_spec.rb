require File.dirname(__FILE__) + '/../spec_helper'
require 'trike/cache/key'

def generate
  parts = []
  parts << @request.scheme << "://"
  parts << @request.host

  if @request.scheme == "https" && @request.port != 443 ||
      @request.scheme == "http" && @request.port != 80
    parts << ":" << @request.port.to_s
  end

  parts << @request.script_name
  parts << @request.path_info

  if qs = query_string
    parts << "?"
    parts << qs
  end

  parts.join
end

describe Trike::Cache::Key do
  
  before do
    @request = mock("request", :scheme => "http", :host => "www.example.com", :port => 80, :script_name => "", :path_info => "/path/to/page/with/slash/", :query_string => "")
  end
  
  it "should normalize the URL by removing a trailing slash" do
    Trike::Cache::Key.call(@request).should == "http://www.example.com/path/to/page/with/slash?"
  end
  
  describe "with query string" do
    
    before do 
      @request.stub!(:query_string).and_return("foo=bar&baz=1")
    end
    
    it "should remove the trailing slash before the query string" do
      #note: the order of the query string is sorted during normaliztion
      Trike::Cache::Key.call(@request).should == "http://www.example.com/path/to/page/with/slash?baz=1&foo=bar"      
    end
    
  end

  describe "without a trailing slash" do
    
    it "should leave the path alone" do
      @request.stub!(:path_info).and_return("/path")
      Trike::Cache::Key.call(@request).should == "http://www.example.com/path?"
    end
    
  end
  
end