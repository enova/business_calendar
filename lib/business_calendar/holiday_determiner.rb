require 'holidays'

class BusinessCalendar::HolidayDeterminer
  DEFAULT_TIME_TO_LIVE = 24 * 60 * 60
  attr_reader :regions, :holiday_names, :additions, :removals, :additions_only

  def initialize(regions, holiday_names, opts = {})
    ttl = opts[:ttl]
    @time_to_live = ttl.nil? ? DEFAULT_TIME_TO_LIVE : ttl
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

  def should_clear_cache?
    return false unless @time_to_live

    !@last_cleared || (Time.now - @last_cleared) >= @time_to_live
  end

  def clear_cache
    @last_cleared = Time.now
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
