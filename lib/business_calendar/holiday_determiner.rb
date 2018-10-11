require 'holidays'

class BusinessCalendar::HolidayDeterminer
  attr_reader :regions, :holiday_names, :additions, :removals, :additions_only

  def initialize(regions, holiday_names, opts = {})
    @regions        = regions
    @holiday_names  = holiday_names
    @additions      = opts[:additions]      || []
    @removals       = opts[:removals]       || []
    @additions_only = opts[:additions_only] || false
  end

  def call(date)
    if additions.include? date
      true
    elsif removals.include? date
      false
    elsif !additions_only
      Holidays.between(date, date, @regions, :observed).
        any? { |h| @holiday_names.include? h[:name] }
    end
  end

  private
  def additions
    @additions.is_a?(Proc) ? @additions.call : @additions
  end

  def removals
    @removals.is_a?(Proc) ? @removals.call : @removals
  end
end
