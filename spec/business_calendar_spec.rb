require 'spec_helper'

describe BusinessCalendar do
  before { Timecop.freeze('2014-04-28'.to_date) }
  subject { BusinessCalendar.for(country) }

  shared_examples_for "standard business time" do
    specify "a weekend is not a business day" do
      subject.is_business_day?('2014-03-09'.to_date).should be_false
    end

    specify "a normal weekday is a business day" do
      subject.is_business_day?('2014-03-10'.to_date).should be_true
    end

    specify "the nearest business days for a series of consecutive days is unique" do
      dates = %w(2014-04-11 2014-04-12 2014-04-13 2014-04-14).map(&:to_date)
      expected = %w(2014-04-11 2014-04-14).map(&:to_date)
      subject.nearest_business_day(dates).should == expected
    end

    specify 'the nearest business day to monday is monday in both directions' do
      subject.nearest_business_day('2014-03-10'.to_date)            .should == '2014-03-10'.to_date
      subject.nearest_business_day('2014-03-10'.to_date, :backward) .should == '2014-03-10'.to_date
      subject.nearest_business_day('2014-03-10'.to_date, :forward)  .should == '2014-03-10'.to_date
    end

    specify 'the nearest business day to a saturday, forward, is monday' do
      subject.nearest_business_day('2014-03-08'.to_date)          .should == '2014-03-10'.to_date
      subject.nearest_business_day('2014-03-08'.to_date, :forward).should == '2014-03-10'.to_date
    end

    specify 'the nearest business day to a saturday, backward, is friday' do
      subject.nearest_business_day('2014-03-08'.to_date, :backward).should == '2014-03-07'.to_date
    end

    specify 'one business day added to a monday is the next day' do
      subject.add_business_day('2014-03-10'.to_date).should == '2014-03-11'.to_date
    end

    specify 'one business day added to a friday is the coming monday' do
      subject.add_business_day('2014-03-07'.to_date).should == '2014-03-10'.to_date
    end

    specify 'one business day added to a weekend is the coming tuesday' do
      subject.add_business_day('2014-03-08'.to_date).should == '2014-03-11'.to_date
    end

    specify 'one business day added to a monday as well as a tuesday is tuesday and wednesday' do
      d1, d2 = subject.add_business_days ['2014-03-10'.to_date, '2014-03-11'.to_date]
      d1.should == '2014-03-11'.to_date
      d2.should == '2014-03-12'.to_date
    end

    specify 'the following business day of a saturday is the coming monday' do
      subject.following_business_day('2014-03-08'.to_date).should == '2014-03-10'.to_date
    end

    specify 'a saturday plus zero business days is the nearest business day, monday' do
      subject.add_business_days('2014-03-08'.to_date, 0).should == '2014-03-10'.to_date
    end

    specify 'a saturday plus zero business days with initial direction backward is the nearest preceding business day, friday' do
      subject.add_business_days('2014-03-08'.to_date, 0, :backward).should == '2014-03-07'.to_date
    end

    specify 'the following business day of a monday is tuesday' do
      subject.following_business_day('2014-03-10'.to_date).should == '2014-03-11'.to_date
    end

    specify 'the preceding business day of a monday is friday' do
      subject.preceding_business_day('2014-03-10'.to_date).should == '2014-03-07'.to_date
    end

    specify 'a monday less three business days is the previous wednesday' do
      subject.add_business_days('2014-03-10'.to_date, -3).should == '2014-03-05'.to_date
    end

    specify 'a saturday less one business day is the previous friday' do
      subject.subtract_business_day('2014-03-08'.to_date).should == '2014-03-07'.to_date
    end
  end

  context "in the US" do
    let(:country) { :US }

    it_behaves_like "standard business time"

    specify "American Independence Day is not a business day" do
      subject.is_business_day?('2014-07-04'.to_date).should be_false
    end
  end

  context "in the UK" do
    let(:country) { :GB }

    it_behaves_like "standard business time"

    specify "American Independence Day is a business day" do
      subject.is_business_day?('2014-07-04'.to_date).should be_true
    end

    specify 'Boxing Day is observed on a weekday' do
      subject.is_business_day?('2015-12-28'.to_date).should be_false
    end
  end

  context "in an unknown country" do
    let(:country) { :GBXX }

    it "raises an informative error when building the calendar" do
      expect { subject }.to raise_error BusinessCalendar::CountryNotSupported
    end
  end
end
