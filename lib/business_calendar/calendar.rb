class BusinessCalendar::Calendar
  # Set timeout to 5 min (300 s)
  TIMEOUT = 300

  attr_reader :holiday_determiner

  # @param [Proc[Date -> Boolean]] a proc which returns whether or not a date is a
  #                                holiday.
  def initialize(holiday_determiner, options = {})
    @options = options
    @holiday_cache = {}
    @holiday_determiner = holiday_determiner
  end

  # @param [Date] date
  # @return [Boolean] Whether or not this calendar's list of holidays includes <date>.
  def is_holiday?(date)
    date = date.send(:to_date) if date.respond_to?(:to_date, true)

    clear_cache if @options["timed_cache"]

    @holiday_cache[date] ||= holiday_determiner.call(date)
  end

  # @param [Date]     date
  # @return [Boolean] Whether or not banking can be done on <date>.
  def is_business_day?(date)
    return false if date.saturday? || date.sunday?
    return false if is_holiday?(date)
    true
  end

  # @param [Date or Array] date_or_dates The day(s) to start from.
  # @param [Integer]       num           Number of days to advance. If negative,
  #                                      this will call `subtract_business_days`.
  # @param [Symbol]        direction     Either `:forward` or `:backward`; the
  #                                      direction to move if today is not a
  #                                      business day.
  # @return [Date] The result of adding <num> business days to <date>.
  # @note 'Adding a business day' means moving one full business day from the
  #       start of the given day -- meaning that adding one business day to a
  #       Saturday will return the following Tuesday, not Monday.
  def add_business_days(date_or_dates, num=1, initial_direction = :forward)
    return subtract_business_days(date_or_dates, -num) if num < 0

    with_one_or_many(date_or_dates) do |date|
      d = nearest_business_day(date, initial_direction)
      num.times { d = following_business_day(d) }
      d
    end
  end
  alias :add_business_day :add_business_days

  # @param [Date or Array] date_or_dates The day(s) to start from.
  # @param [Integer]       num           Number of days to retreat. If negative,
  #                                      this will call `add_business_days`.
  # @return [Date] The business date to which adding <num> business dats
  #                would arrive at <date>.
  def subtract_business_days(date_or_dates, num=1)
    return add_business_days(date_or_dates, -num) if num < 0

    with_one_or_many(date_or_dates) do |date|
      num.times { date = preceding_business_day(date) }
      date
    end
  end
  alias :subtract_business_day :subtract_business_days

  # @param [Date or Array] date_or_dates The day(s) to start from.
  # @return [Date] The business day immediately prior to <date>.
  def preceding_business_day(date_or_dates)
    with_one_or_many(date_or_dates) do |date|
      begin
        date = date - 1
      end until is_business_day? date

      date
    end
  end

  # @param [Date or Array] date_or_dates The day(s) to start from.
  # @param [Symbol]        direction     Either `:forward` or `:backward`; the
  #                                      direction to move if today is not a
  #                                      business day.
  # @return [Date] The nearest (going <direction> in time) business day from
  #                <date>. If <date> is already a business day, it will be returned.
  def nearest_business_day(date_or_dates, direction = :forward)
    with_one_or_many(date_or_dates) do |date|
      until is_business_day? date
        date += case direction
                when :forward
                  1
                when :backward
                  -1
                else
                  raise ArgumentError, "Invalid direction supplied: '#{direction}' should instead be :forward or :backward"
                end
      end

      date
    end
  end

  # @param [Date or Array] date_or_dates The day(s) to start from.
  # @return [Date] The nearest (going forward in time) business day from <date>
  #                which is not <date> itself.
  def following_business_day(date_or_dates)
    with_one_or_many(date_or_dates) do |date|
      nearest_business_day(date + 1)
    end
  end

  private
  def with_one_or_many(thing_or_things)
    if thing_or_things.is_a? Enumerable
      thing_or_things.collect do |thing|
        yield thing
      end
    else
      yield thing_or_things
    end
  end

  def clear_cache
    if !@issued_at || (Time.now - @issued_at) >= TIMEOUT
      @issued_at = Time.now
      @holiday_cache = {}
    end
  end
end
