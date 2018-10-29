require 'spec_helper'

describe BusinessCalendar do
  before { allow(Date).to receive(:today).and_return('2014-04-28'.to_date) }
  subject { BusinessCalendar.for(country) }

  shared_examples_for "standard business time" do
    specify "a weekend is not a business day" do
      expect(subject.is_business_day?('2014-03-09'.to_date)).to be false
    end

    specify "a normal weekday is a business day" do
      expect(subject.is_business_day?('2014-03-10'.to_date)).to be true
    end

    specify 'the nearest business day to monday is monday in both directions' do
      expect(subject.nearest_business_day('2014-03-10'.to_date)).to eq '2014-03-10'.to_date
      expect(subject.nearest_business_day('2014-03-10'.to_date, :backward)).to eq '2014-03-10'.to_date
      expect(subject.nearest_business_day('2014-03-10'.to_date, :forward)).to eq '2014-03-10'.to_date
    end

    specify 'the nearest business day to a saturday, forward, is monday' do
      expect(subject.nearest_business_day('2014-03-08'.to_date)).to eq '2014-03-10'.to_date
      expect(subject.nearest_business_day('2014-03-08'.to_date, :forward)).to eq '2014-03-10'.to_date
    end

    specify 'the nearest business day to a saturday, backward, is friday' do
      expect(subject.nearest_business_day('2014-03-08'.to_date, :backward)).to eq '2014-03-07'.to_date
    end

    specify 'one business day added to a monday is the next day' do
      expect(subject.add_business_day('2014-03-10'.to_date)).to eq '2014-03-11'.to_date
    end

    specify 'one business day added to a friday is the coming monday' do
      expect(subject.add_business_day('2014-03-07'.to_date)).to eq '2014-03-10'.to_date
    end

    specify 'one business day added to a weekend is the coming tuesday' do
      expect(subject.add_business_day('2014-03-08'.to_date)).to eq '2014-03-11'.to_date
    end

    specify 'one business day added to a monday as well as a tuesday is tuesday and wednesday' do
      d1, d2 = subject.add_business_days ['2014-03-10'.to_date, '2014-03-11'.to_date]
      expect(d1).to eq '2014-03-11'.to_date
      expect(d2).to eq '2014-03-12'.to_date
    end

    specify 'the following business day of a saturday is the coming monday' do
      expect(subject.following_business_day('2014-03-08'.to_date)).to eq '2014-03-10'.to_date
    end

    specify 'a saturday plus zero business days is the nearest business day, monday' do
      expect(subject.add_business_days('2014-03-08'.to_date, 0)).to eq '2014-03-10'.to_date
    end

    specify 'a saturday plus zero business days with initial direction backward is the nearest preceding business day, friday' do
      expect(subject.add_business_days('2014-03-08'.to_date, 0, :backward)).to eq '2014-03-07'.to_date
    end

    specify 'the following business day of a monday is tuesday' do
      expect(subject.following_business_day('2014-03-10'.to_date)).to eq '2014-03-11'.to_date
    end

    specify 'the preceding business day of a monday is friday' do
      expect(subject.preceding_business_day('2014-03-10'.to_date)).to eq '2014-03-07'.to_date
    end

    specify 'a monday less three business days is the previous wednesday' do
      expect(subject.add_business_days('2014-03-10'.to_date, -3)).to eq '2014-03-05'.to_date
    end

    specify 'a saturday less one business day is the previous friday' do
      expect(subject.subtract_business_day('2014-03-08'.to_date)).to eq '2014-03-07'.to_date
    end
  end

  shared_examples_for "weekends as business days" do
    specify "a weekend is a business day" do
      expect(subject.is_business_day?('2014-03-09'.to_date)).to be true
    end

    specify "a normal weekday is a business day" do
      expect(subject.is_business_day?('2014-03-10'.to_date)).to be true
    end

    specify 'the nearest business day to a saturday in any direction is saturday' do
      expect(subject.nearest_business_day('2014-03-08'.to_date)).to eq '2014-03-08'.to_date
      expect(subject.nearest_business_day('2014-03-08'.to_date, :forward)).to eq '2014-03-08'.to_date
      expect(subject.nearest_business_day('2014-03-08'.to_date, :backward)).to eq '2014-03-08'.to_date
    end

    specify 'one business day added to a friday is saturday' do
      expect(subject.add_business_day('2014-03-07'.to_date)).to eq '2014-03-08'.to_date
    end

    specify 'one business day added to a weekend is the next day' do
      expect(subject.add_business_day('2014-03-08'.to_date)).to eq '2014-03-09'.to_date
      expect(subject.add_business_day('2014-03-09'.to_date)).to eq '2014-03-10'.to_date
    end

    specify 'the following business day of a saturday is sunday' do
      expect(subject.following_business_day('2014-03-08'.to_date)).to eq '2014-03-09'.to_date
    end

    specify 'a saturday plus zero business days is still saturday' do
      expect(subject.add_business_days('2014-03-08'.to_date, 0)).to eq '2014-03-08'.to_date
      expect(subject.add_business_days('2014-03-08'.to_date, 0, :backward)).to eq '2014-03-08'.to_date
    end

    specify 'the preceding business day of a monday is sunday' do
      expect(subject.preceding_business_day('2014-03-10'.to_date)).to eq '2014-03-09'.to_date
    end

    specify 'a monday less three business days is the previous friday' do
      expect(subject.add_business_days('2014-03-10'.to_date, -3)).to eq '2014-03-07'.to_date
    end
  end

  context "in the US" do
    let(:country) { :US }

    it_behaves_like "standard business time"

    context "with weekends as business days" do
      subject { BusinessCalendar.for(country, {"business_weekends" => true}) }

      it_behaves_like "weekends as business days"
    end

    specify "American Independence Day is not a business day" do
      expect(subject.is_business_day?('2014-07-04'.to_date)).to be false
    end

    specify 'a time is converted to a date' do
      expect(subject.is_holiday?(Time.parse('2014-07-04'))).to be true
    end
  end

  context "in the UK" do
    let(:country) { :GB }

    it_behaves_like "standard business time"

    context "with weekends as business days" do
      subject { BusinessCalendar.for(country, {"business_weekends" => true}) }

      it_behaves_like "weekends as business days"
    end

    specify "American Independence Day is a business day" do
      expect(subject.is_business_day?('2014-07-04'.to_date)).to be true
    end

    specify 'Boxing Day is not observed on the next weekday' do
      expect(subject.is_business_day?('2015-12-28'.to_date)).to be true
    end
  end

  context "in an unknown country" do
    let(:country) { :GBXX }

    it "raises an informative error when building the calendar" do
      expect { subject }.to raise_error BusinessCalendar::CountryNotSupported
    end
  end

  context "with an API endpoint", focus: true do
    let(:additions) { 'http://fakeendpoint.test/additions' }
    let(:removals) { 'http://fakeendpoint.test/removals' }

    subject { BusinessCalendar.for_endpoint(additions, removals) }

    before do
      stub_request(:get, additions).to_return(
        status: 200,
        body: {'holidays' => ['2014-07-04', '2014-07-05']}.to_json
      )

      stub_request(:get, removals).to_return(
        status: 200,
        body: {'holidays' => ['2014-12-24', '2014-12-25']}.to_json
      )
    end

    it_behaves_like "standard business time"

    context "with weekends as business days" do
      subject { BusinessCalendar.for_endpoint(additions, removals, {"business_weekends" => true}) }

      it_behaves_like "weekends as business days"
    end

    it 'hits the configured endpoint for each call to an addition or removal' do
      subject.is_business_day?('2014-07-03'.to_date)
      subject.is_business_day?('2014-07-04'.to_date)
      subject.is_holiday?('2014-07-06'.to_date)
      subject.is_holiday?('2014-12-24'.to_date)

      expect(a_request(:get, additions)).to have_been_made.times(4)
      expect(a_request(:get, removals)).to have_been_made.times(3)
    end

    it 'caches holidays for 5 min' do
      Timecop.freeze(Time.now)

      subject.is_business_day?('2014-07-04'.to_date)
      subject.is_business_day?('2014-07-04'.to_date)

      expect(a_request(:get, additions)).to have_been_made.times(1)

      Timecop.freeze(Time.now + 301)

      subject.is_business_day?('2014-07-04'.to_date)

      expect(a_request(:get, additions)).to have_been_made.times(2)
    end

    context 'http request fails' do
      before { stub_request(:get, additions).to_return(status: 500) }

      it 'raises an error' do
        expect { subject.is_business_day?('2014-07-04'.to_date) }.to raise_error Faraday::ClientError
      end
    end

    specify "date included in endpoint's holiday list is not a business day" do
      expect(subject.is_business_day?('2014-07-05'.to_date)).to be false
    end

    specify 'a time is converted to a date' do
      expect(subject.is_holiday?(Time.parse('2014-07-04'))).to be true
    end
  end
end
