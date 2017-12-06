require 'spec_helper'

describe "Organization bank holidays" do
  %w(
    2017-01-01
    2017-01-25
    2017-02-27
    2017-02-28
    2017-04-14
    2017-04-21
    2017-05-01
    2017-06-15
    2017-09-07
    2017-10-12
    2017-11-02
    2017-11-15
    2017-11-20
    2017-12-25
    2018-01-01
    2018-01-25
    2018-02-12
    2018-02-13
    2018-03-30
    2018-04-21
    2018-05-01
    2018-05-31
    2018-09-07
    2018-10-12
    2018-11-02
    2018-11-15
    2018-11-20
    2018-12-25
    ).map { |x| Date.parse x }.each do |expected_holiday|
    it "treats #{expected_holiday} as a holiday" do
      expect(BusinessCalendar.for_organization(:captalys).is_holiday?(expected_holiday)).to be true
    end
  end

  %w(
      2018-12-26
      2017-01-02
    ).map { |x| Date.parse x }.each do |date|
    it "treats #{date} as not a holiday" do
      expect(BusinessCalendar.for_organization(:captalys).is_holiday?(date)).to be false
    end
  end

  # Saturday and Sunday
  %w(
      2018-11-25
      2017-11-26
    ).map { |x| Date.parse x }.each do |date|
    it "treats #{date} as not a business day" do
      expect(BusinessCalendar.for_organization(:captalys).is_business_day?(date)).to be false
    end
  end

  it "calculates previous business day correctly" do
    expect(BusinessCalendar.for_organization(:captalys).preceding_business_day(Date.parse('2018-11-19'))).to eq (Date.parse('2018-11-16'))
  end

  it "calculates next business day correctly" do
    expect(BusinessCalendar.for_organization(:captalys).following_business_day(Date.parse('2018-11-19'))).to eq (Date.parse('2018-11-21'))
  end
end
