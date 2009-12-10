require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CacheWriter do
  describe "running" do
    before do
      @cache_writer = CacheWriter.new
      FileUtils.stub! :touch
    end

    after do
      @cache_writer.run
    end

    describe "with a sitemap" do
      before do
        @cache_writer.stub!(:sitemap_exists?).and_return true
        @cache_writer.stub! :spider_sitemap
      end

      it "should not try and spider the homepage" do
        @cache_writer.should_not_receive :spider_homepage
      end

      it "should try spider the sitemap if it exists" do
        @cache_writer.should_receive :spider_sitemap
      end
    end

    describe "without a sitemap" do
      before do
        @cache_writer.stub!(:sitemap_exists?).and_return false
        @cache_writer.stub! :spider_homepage
      end

      it "should not try and spider the sitemap" do
        @cache_writer.should_not_receive :spider_sitemap
      end

      it "should spider the index for links" do
        @cache_writer.should_receive :spider_homepage
      end
    end

    it "should touch .last_spider on successful completion" do
      @cache_writer.stub!(:sitemap_exists?).and_return true
      @cache_writer.stub! :spider_sitemap
      FileUtils.should_receive(:touch).with(File.join(StaticCachingExtension::STATIC_CACHE_DIR, '.last_spider'))
    end
  end

  describe "spidering sitemap" do
    # TODO
  end

  describe "spidering homepage" do
    # TODO
  end

  describe "priming" do
    before do
      @cache_writer = CacheWriter.new
      @cache_writer.stub! :run
      CacheWriter.stub!(:new).and_return(@cache_writer)
    end

    it "should run a cache writer" do
      @cache_writer.should_receive :run
      CacheWriter.prime!
    end
  end

  describe "refreshing when" do
    before do
      CacheWriter.stub :prime!
    end

    after do
      CacheWriter.refresh!
    end

    describe "last_spider doesn't exist" do
      before do
        CacheWriter.stub!(:last_edit).and_return 1.hour.ago
        CacheWriter.stub!(:last_spider).and_return nil
      end

      it "should prime the caches" do
        CacheWriter.should_receive :prime!
      end
    end

    describe "last_spider does exist" do
      before do
        CacheWriter.stub!(:last_spider).and_return 1.hour.ago
      end

      describe "and last_edit doesn't exist" do
        before do
          CacheWriter.stub!(:last_edit).and_return nil
        end

        it "should not prime the caches" do
          CacheWriter.should_not_receive :prime!
        end
      end

      describe "and last_edit is more recent than last_spider" do
        describe "and last_edit was less than 20 minutes ago" do
          it "should not prime the caches" do
            CacheWriter.stub!(:last_edit).and_return 10.minutes.ago
            CacheWriter.should_not_receive :prime!
          end
        end

        describe "and last_edit was over 20 minutes ago" do
          it "should prime the caches" do
            CacheWriter.stub!(:last_edit).and_return 30.minutes.ago
            CacheWriter.should_receive :prime!
          end
        end
      end

      describe "and last_edit is older than last_spider" do
        before do
          CacheWriter.stub!(:last_edit).and_return 2.days.ago
        end

        it "should not prime the caches" do
          CacheWriter.should_not_receive :prime!
        end
      end
    end
  end
end