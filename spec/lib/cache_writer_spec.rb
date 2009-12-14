require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CacheWriter do
  describe "running" do
    before do
      @cache_writer = CacheWriter.new
      FileUtils.stub! :touch
    end

    describe "with a sitemap" do
      before do
        @cache_writer.stub!(:sitemap_exists?).and_return true
        @cache_writer.stub! :spider_sitemap
      end

      after do
        @cache_writer.run
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

      after do
        @cache_writer.run
      end

      it "should not try and spider the sitemap" do
        @cache_writer.should_not_receive :spider_sitemap
      end

      it "should spider the index for links" do
        @cache_writer.should_receive :spider_homepage
      end
    end

    it "should touch .last_spider_attempt regardless of completion" do
      @cache_writer.stub!(:sitemap_exists?).and_return true
      @cache_writer.stub!(:spider_sitemap).and_raise
      FileUtils.should_receive(:touch).with(File.join(ResponseCacheConfig.cache_dir, '.last_spider_attempt'))

      lambda {
        @cache_writer.run
      }.should raise_error
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

  describe "freshness: when" do
    subject { CacheWriter }

    describe "last_edit exists" do
      describe "and is older than 20 minutes" do
        before do
          CacheWriter.stub!(:last_edit).and_return 1.hour.ago
        end

        describe "and last_spider_attempt is older than last_edit" do
          before do
            CacheWriter.stub!(:last_spider_attempt).and_return 2.hours.ago
          end

          it { should_not be_fresh }
        end

        describe "and last_spider_attempt is younger than last_edit" do
          before do
            CacheWriter.stub!(:last_spider_attempt).and_return 10.minutes.ago
          end

          it { should be_fresh }
        end

        describe "and last_spider_attempt doesn't exist" do
          before do
            CacheWriter.stub!(:last_spider_attempt).and_return nil
          end

          it { should_not be_fresh }
        end
      end

      describe "and is less than 20 minutes old" do
        before do
          CacheWriter.stub!(:last_edit).and_return 10.minutes.ago
        end

        it { should be_fresh }
      end
    end

    describe "last_edit doesn't exist" do
      before do
        CacheWriter.stub!(:last_edit).and_return nil
      end

      describe "and last_spider_attempt does exist" do
        before do
          CacheWriter.stub!(:last_spider_attempt).and_return 1.hour.ago
        end

        it { should be_fresh }
      end

      describe "and last_spider_attempt doesn't exist" do
        before do
          CacheWriter.stub!(:last_spider_attempt).and_return nil
        end

        it { should_not be_fresh }
      end
    end
  end
end