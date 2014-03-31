require 'spec_helper'

describe "GB bank holidays" do
  %w(
      2012-06-04
      2014-04-18
      2014-04-21
      2014-05-05
      2014-05-26
      2014-08-25
      2014-12-25
      2014-12-26
      2015-01-01
      2015-04-03
      2015-04-06
      2015-05-04
      2015-05-25
      2015-08-31
      2015-12-25
      2015-12-28
    ).map { |x| Date.parse x }.each do |expected_holiday|
    it "treats #{expected_holiday} as a holiday" do
      BusinessCalendar.for(:GB).is_holiday?(expected_holiday).should be_true
    end
  end

  %w(
      2012-05-28
    ).map { |x| Date.parse x }.each do |date|
    it "treats #{date} as not a holiday" do
      BusinessCalendar.for(:GB).is_holiday?(date).should be_false
    end
  end
end
