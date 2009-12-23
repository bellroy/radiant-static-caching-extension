require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CacheWriter do
  describe "running" do
    before do
      @cache_writer = CacheWriter.new
      FileUtils.stub! :touch
      FileUtils.stub! :mkdir_p
      @cache_writer.stub!(:sitemap_exists?).and_return true
      @cache_writer.stub! :spider_sitemap
    end

    describe "successfully" do
      before do
        CacheWriter.stub! :ensure_cache_dir
      end

      describe "with a sitemap" do
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
    end

    describe "regardless of completion" do
      after do
        @cache_writer.run
      end

      it "should try and create the cache directory if it doesn't exist" do
        CacheWriter.stub!(:cache_dir_exists?).and_return false
        FileUtils.should_receive(:mkdir_p).with File.join(ResponseCacheConfig.cache_dir)
      end

      it "should touch .last_spider_attempt regardless of completion" do
        FileUtils.should_receive(:touch).with(File.join(ResponseCacheConfig.cache_dir, '.last_spider_attempt'))
      end
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
      CacheWriter.stub!(:new).and_return @cache_writer
    end

    it "should run a cache writer" do
      @cache_writer.should_receive :run
      CacheWriter.prime!
    end

    describe "with lock" do
      after do
        CacheWriter.prime_with_locking! 20
      end

      it "should check for lock files" do
        Dir.should_receive(:glob).with(File.join(Dir::tmpdir, 'radiant_sites_static_cache_lock.*')).and_return []
      end

      it "should not prime if there are more than max_spiders lock files" do
        Dir.stub!(:glob).and_return Array.new(40)
        CacheWriter.should_not_receive :prime!
      end

      it "should create a temporary lock file" do
        Tempfile.should_receive(:open).with 'radiant_sites_static_cache_lock'
      end

      it "should prime the cache normally" do
        CacheWriter.should_receive :prime!
      end
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
