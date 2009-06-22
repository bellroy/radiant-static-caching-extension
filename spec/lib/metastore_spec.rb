require File.dirname(__FILE__) + '/../spec_helper'
require 'trike/cache/metastore'

describe Trike::MetaStore do
  
  before do
    @store = Trike::MetaStore.new
  end
  
  describe "#store" do
    
    it "should pass the content type and key to the EntityStore" do
      request = mock('request', :vary => nil)
      response = mock('response',
        :headers => { 'Content-Type' => 'text/html' },
        :body => 'Some body text',
        :body=  => nil,
        :vary => nil
      )
      
      @store.stub!(:cache_key).and_return('http://example.net/page')
      @store.stub!(:persist_request)
      @store.stub!(:persist_response).and_return( response.headers )
      @store.stub!(:requests_match?).and_return(true)
      @store.stub!(:write)
            
      entity_store = mock('EntityStore')
      entity_store.stub!(:open)
      entity_store.should_receive(:write).with('Some body text', 'text/html', 'http://example.net/page')
      
      @store.store(request, response, entity_store)
    end
    
  end
  
end