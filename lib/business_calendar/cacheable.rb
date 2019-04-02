module BusinessCalendar
  # Helper parent class for periodically clearing memoized attributes,
  # such as the parsed result of an API call.
  # This class merely acts as a timing mechanism,
  # the subclass / caller is responsible for the real work.
  class Cacheable
    DEFAULT_TIME_TO_LIVE = 24 * 60 * 60

    # @param [Integer or NilClass] ttl
    #     Time to Live in seconds,
    #     the time until cache should be considered expired.
    #     `nil` defaults back to the default time for backwards compatibility.
    #     Use `false` for "never clear cache".
    #     Use `0` for "always clear cache".
    def initialize(ttl = DEFAULT_TIME_TO_LIVE)
      @time_to_live = ttl.nil? ? DEFAULT_TIME_TO_LIVE : ttl
    end

    private

    def should_clear_cache?
      return false unless @time_to_live

      !@last_cleared || (Time.now - @last_cleared) >= @time_to_live
    end

    def clear_cache
      @last_cleared = Time.now
      # subclass should:
      # - override this method
      # - call `super`
      # - clear relevant memoized attribute(s) of choice
      # After calling this method,
      # caller will potentially populate new data into the memoized attribute(s).
      # Example usage:
      #   clear_cache if should_clear_cache?
      #   @thing_cache ||= get_things.call
    end
  end
end
