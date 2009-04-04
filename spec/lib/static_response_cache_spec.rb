require File.dirname(__FILE__) + '/../spec_helper'

class TestResponseCache
  def perform_caching; true; end
  def cache_page;end
  include StaticResponseCache
end

describe 'StaticResponseCache' do
  before(:each) do
    @cache = TestResponseCache.new
    @cache.stub!(:logger).and_return(ActiveRecord::Base.logger)
  end

  describe 'getting static cache path' do
    
    it 'should delegate to page_cache_path' do
      @cache.should_receive(:page_cache_path).with('/path/to/document').and_return('path')
      @cache.static_cache_path('/path/to/document')
    end
    
    it 'should change the page_cache_path for _site-root to index' do
      @cache.stub!(:page_cache_path).and_return('path/_site-root')
      @cache.static_cache_path('/path/to/document').should == 'path/index'
    end
  end
  
  describe 'static caching of content' do
    before(:each) do
      FileUtils.stub!(:makedirs)
      YAML.stub!(:load).and_return({})
    end

    it 'should add .cached.html to the cached path if no extension' do
      @cache.stub!(:static_cache_path).and_return('path/to/doc')
      File.should_receive(:open).with('path/to/doc.cache.html', 'wb')
      @cache.cache_page_with_static('yaml', 'document', 'path')
    end

    it 'should add .cached.html to the cached path if extension is .seo' do
      @cache.stub!(:static_cache_path).and_return('path/to/doc.seo')
      File.should_receive(:open).with('path/to/doc.seo.cache.html', 'wb')
      @cache.cache_page_with_static('yaml', 'document', 'path')
    end

    it 'should leave the cached path alone if it has an extension and that extension is not .seo' do
      @cache.stub!(:static_cache_path).and_return('path/to/doc.css')
      File.should_receive(:open).with('path/to/doc.css', 'wb')

      @cache.cache_page_with_static('yaml', 'document', 'path')
    end

    it 'should make sure the caching dir exists' do
      @cache.stub!(:static_cache_path).and_return('path/to/doc')
      File.stub!(:open)
      FileUtils.should_receive(:makedirs).with('path/to')

      @cache.cache_page_with_static('yaml', 'document', 'path')
    end

    it 'should write the content to the cached path' do
      @cache.stub!(:static_cache_path).and_return('path/to/doc')
      file = mock('file')
      file.should_receive('write').with('document')
      File.stub!(:open).and_yield(file)
      
      @cache.cache_page_with_static('yaml', 'document', 'path')
    end

    it 'should log cache name collisions' do
      @cache.stub!(:static_cache_path).and_return('path/to/doc')
      FileUtils.stub!(:makedirs).and_raise(Errno::EEXIST)
      ActiveRecord::Base.logger.should_receive(:error)

      @cache.cache_page_with_static('yaml', 'document', 'path')
    end
  end

end
