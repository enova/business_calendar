require 'faraday'

module BusinessCalendar
  CountryNotSupported = Class.new(StandardError)
  OrganizationNotSupported = Class.new(StandardError)
  class << self
    def for(country, options = {})
      if options["use_cached_calendar"]
        calendar_cache[country] ||= Calendar.new(holiday_determiner(country))
      else
        Calendar.new(holiday_determiner(country), options)
      end
    end

    def for_organization(org, options = {})
      Calendar.new(holiday_determiner_for_organization(org), options)
    end

    def for_endpoint(additions, removals, options = {})
      Calendar.new(holiday_determiner_for_endpoint(additions, removals, options), options)
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

    def holiday_dates_for_endpoint(client, endpoint)
      Proc.new { JSON.parse(client.get(endpoint).body).fetch('holidays').map { |s| Date.parse s } }
    end

    def holiday_determiner_for_endpoint(additions_endpoint, removals_endpoint, opts)
      client = Faraday.new do |conn|
        conn.response :raise_error
        conn.adapter :net_http
      end

      additions = if additions_endpoint
                    holiday_dates_for_endpoint(client, additions_endpoint)
                  end

      removals = if removals_endpoint
                   holiday_dates_for_endpoint(client, removals_endpoint)
                 end

      HolidayDeterminer.new(
        opts["regions"] || [],
        opts["holiday_names"] || [],
        :additions       => additions,
        :removals        => removals,
        :additions_only  => opts["additions_only"] || [],
        :ttl => opts['ttl']
      )
    end

    def calendar_cache
      @calendar_cache ||= {}
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
