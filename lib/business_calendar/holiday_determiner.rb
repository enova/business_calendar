require 'holidays'
require 'business_calendar/cacheable'

class BusinessCalendar::HolidayDeterminer < BusinessCalendar::Cacheable
  attr_reader :regions, :holiday_names, :additions, :removals, :additions_only

  def initialize(regions, holiday_names, opts = {})
    super(opts[:ttl])
    @regions        = regions
    @holiday_names  = holiday_names
    @additions      = opts[:additions]      || []
    @removals       = opts[:removals]       || []
    @additions_only = opts[:additions_only] || false
  end

  def call(date)
    clear_cache if should_clear_cache?

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

  def clear_cache
    super
    @additions_cache = nil
    @removals_cache = nil
  end

  def additions
    @additions_cache ||= @additions.is_a?(Proc) ? @additions.call : @additions
  end

  def removals
    @removals_cache ||= @removals.is_a?(Proc) ? @removals.call : @removals
  end
end
