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
      2015-12-26
      2016-12-25
      2017-01-01
      2020-12-28
      2021-12-27
      2021-12-28
      2022-01-03
      2022-12-27
      2023-01-02
    ).map { |x| Date.parse x }.each do |expected_holiday|
    it "treats #{expected_holiday} as a holiday" do
      expect(BusinessCalendar.for(:GB).is_holiday?(expected_holiday)).to be true
    end
  end

  %w(
      2012-05-28
      2015-12-28
      2020-12-26
      2021-12-25
      2021-12-26
      2022-01-01
      2022-12-25
      2023-01-01
    ).map { |x| Date.parse x }.each do |date|
    it "treats #{date} as not a holiday" do
      expect(BusinessCalendar.for(:GB).is_holiday?(date)).to be false
    end
  end
end
