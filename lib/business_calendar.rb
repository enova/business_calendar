module BusinessCalendar
  CountryNotSupported = Class.new(StandardError)
  OrganizationNotSupported = Class.new(StandardError)
  class << self
    def for(country)
      Calendar.new(holiday_determiner(country))
    end

    def for_organization(org)
      Calendar.new(holiday_determiner_for_organization(org))
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

    def holiday_determiner_for_organization(org)
      cfg = org_config(org) or raise OrganizationNotSupported.new(org.inspect)
      @holiday_procs ||= {}
      @holiday_procs[org] ||= HolidayDeterminer.new(
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

    def org_config(org)
      @org_config ||= load_config_for_organizations
      @org_config[org.to_s]
    end

    def load_config_for_organizations
      files = Dir[File.join(File.dirname(File.expand_path(__FILE__)), '../data/org/*.yml')]

      files.reduce({}) { |hash, file| hash.merge! YAML.load_file(file) }
    end
  end
end

require 'yaml'
require 'business_calendar/ruby18_shim' if RUBY_VERSION == '1.8.7'
require 'business_calendar/calendar'
require 'business_calendar/holiday_determiner'
