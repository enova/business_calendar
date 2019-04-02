require 'spec_helper'

describe BusinessCalendar::Cacheable do
  subject do
    class FakeCacheableThing < described_class
      def should_clear_cache?
        super
      end
      def clear_cache
        super
      end
    end
    FakeCacheableThing.new
  end
  let!(:start) { Time.now }
  let!(:over_one_day) { 86401 }

  describe '#should_clear_cache?' do
    it 'will indicate a stale cache after default Time to Live is exceeded' do
      allow(Time).to receive(:now) { start }

      # initialize timing variable
      subject.clear_cache

      expect(subject.should_clear_cache?).to be(false)

      allow(Time).to receive(:now) { start + over_one_day }
      expect(subject.should_clear_cache?).to be(true)
    end

    context 'Time to Live specified' do
      subject { FakeCacheableThing.new(40) }
      it 'will indicate a stale cache after specified Time to Live is exceeded' do
        allow(Time).to receive(:now) { start }

        # initialize timing variable
        subject.clear_cache

        expect(subject.should_clear_cache?).to be(false)

        allow(Time).to receive(:now) { start + 39 }
        expect(subject.should_clear_cache?).to be(false)

        allow(Time).to receive(:now) { start + 41 }
        expect(subject.should_clear_cache?).to be(true)
      end
    end
  end

  describe '#clear_cache' do
    it 'indicates a refreshed cache on the object' do
      allow(Time).to receive(:now) { start }

      # we start needing to "clear" the cache before our first call to `clear_cache`,
      # (this should actually be used to initialize it, not clear it)
      expect(subject.should_clear_cache?).to be(true)

      # initialize timing variable
      subject.clear_cache
      expect(subject.should_clear_cache?).to be(false)

      # exceed default time
      allow(Time).to receive(:now) { start + over_one_day }
      expect(subject.should_clear_cache?).to be(true)

      subject.clear_cache
      expect(subject.should_clear_cache?).to be(false)
    end
  end
end
