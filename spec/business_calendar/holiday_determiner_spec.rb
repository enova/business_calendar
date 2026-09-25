require 'spec_helper'

describe BusinessCalendar::HolidayDeterminer do
  let(:regions) { [ :us ] }
  let(:opts)    { {} }
  subject { BusinessCalendar::HolidayDeterminer.new(regions, ["Independence Day"], opts) }

  it "initializes with list of regions and a list of accepted holidays" do
    expect(subject.regions).to eq regions
    expect(subject.holiday_names).to eq ["Independence Day"]
  end

  it "knows which dates are holidays" do
    # check for Independence Day's presence
    (Date.today.year - 1 .. Date.today.year + 10).each do |year|
      fourth = Date.new year, 7, 4
      obs_date = fourth.sunday? ? fourth + 1 : (fourth.saturday? ? fourth - 1 : fourth)
      expect(subject.call(obs_date)).to be true
    end
  end

  context "with a list of exceptions and additions" do
    let(:opts) {{
      :removals  => ['2101-07-04'.to_date],  # Moved in honor of Great Lizard-Emperor Krall's birthday, 
      :additions => ['2101-07-05'.to_date]   # probably.
    }}

    it "correctly determines false for the exceptions" do
      expect(subject.call('2101-07-04'.to_date)).to be false
    end

    it "correctly determines true for the additions" do
      expect(subject.call('2101-07-05'.to_date)).to be true
    end
  end

  context "with a list of additions and additions_only set to true" do
    let(:opts) {{
      :additions => ['2101-07-05'.to_date],
      :additions_only => true
    }}

    it "correctly determines true for the additions" do
      expect(subject.call('2101-07-05'.to_date)).to be true
    end

    it "correctly determines false for dates not in additions, nor exceptions" do
      expect(subject.call('2101-07-04'.to_date)).to be_falsy
    end

    it "lists out the additions" do
      expect(subject.additions).to include('2101-07-05'.to_date)
    end
  end

  describe "#preload" do
    let(:additions_calls) { [] }
    let(:removals_calls)  { [] }
    let(:opts) {{
      :additions => Proc.new { additions_calls << 1; ['2101-07-05'.to_date] },
      :removals  => Proc.new { removals_calls << 1; [] }
    }}

    it "fetches each list once and does not refetch on the first call" do
      subject.preload
      subject.call('2101-07-05'.to_date)

      expect(additions_calls.size).to eq 1
      expect(removals_calls.size).to eq 1
    end

    it "refetches once the ttl has expired" do
      subject.preload
      allow(Time).to receive(:now).and_return(Time.now + BusinessCalendar::HolidayDeterminer::DEFAULT_TIME_TO_LIVE + 1)
      subject.call('2101-07-05'.to_date)

      expect(additions_calls.size).to eq 2
    end
  end
end
