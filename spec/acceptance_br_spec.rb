require 'spec_helper'

describe "BR bank holidays" do
  %w(
      2014-01-01
      2014-04-21
      2014-05-01
      2014-09-07
      2014-10-12
      2014-11-02
      2014-11-15
      2014-12-25
      2015-01-01
      2015-04-21
      2015-05-01
      2015-09-07
      2015-10-12
      2015-11-02
      2015-11-15
      2015-12-25
    ).map { |x| Date.parse x }.each do |expected_holiday|
    it "treats #{expected_holiday} as a holiday" do
      expect(BusinessCalendar.for(:BR).is_holiday?(expected_holiday)).to be true
    end
  end

  # Carnival days
  %w(
      2014-02-28
      2014-03-03
      2014-03-04
    ).map { |x| Date.parse x }.each do |date|
    it "treats #{date} as not a holiday" do
      expect(BusinessCalendar.for(:BR).is_holiday?(date)).to be false
    end
  end
end
