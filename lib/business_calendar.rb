module BusinessCalendar
  CountryNotSupported = Class.new(StandardError)
  class << self
    def for(country)
      Calendar.new(holiday_determiner(country))
    end

    private

    def holiday_determiner(country)
      cfg = config(country) or raise CountryNotSupported.new(country.inspect)
      @holiday_procs ||= {}
      @holiday_procs[country] ||= HolidayDeterminer.new(
         cfg["regions"],
         cfg["holiday_names"],
         :additions       => (cfg["additions"] || []).map { |s| Date.parse s },
         :removals        => (cfg["removals"]  || []).map { |s| Date.parse s },
         :additions_only  => cfg['additions_only'] )
    end

    def config(country)
      @config ||= load_config
      @config[country.to_s]
    end

    def load_config
      files = Dir[File.join(File.dirname(File.expand_path(__FILE__)), '../data/*.yml')]

      files.reduce({}) { |hash, file| hash.merge! YAML.load_file(file) }
    end
  end
end

require 'yaml'
require 'business_calendar/shim'
require 'business_calendar/calendar'
require 'business_calendar/holiday_determiner'
