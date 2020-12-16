# BusinessCalendar

[![Gem Version](https://badge.fury.io/rb/business_calendar.svg)](https://rubygems.org/gems/business_calendar)
[![Dependency Status](https://gemnasium.com/enova/business_calendar.svg)](https://gemnasium.com/enova/business_calendar)

Need to know what days you can actually debit a customer on in excruciating detail? Fed up with singleton-based gems 
that can't handle your complex, multi-international special needs? *So* over extending core objects like Numeric
and Date just to make your code a little cleaner? Well, do I have the gem for you! **BusinessCalendar** is a
reasonably light-weight solution, concerned primarily with banking holidays in different countries.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'business_calendar'
```

And then execute:

    $ bundle

## Usage

### Basic usage

Instantiate a calendar object with:

```ruby
bc = BusinessCalendar.for(:US)
```

This will automatically load holidays based on the US banking holiday schedule, as configured in `data/holidays.yml`. 
Currently, this gem supports `:GB` and `:US` regions.

Now, you can use it:

```ruby
bc.is_business_day? Date.parse('2014-03-10')        # => true
bc.add_business_day Date.parse('2014-03-10')        # => #<Date 2014-03-11>
bc.nearest_business_day Date.parse('2014-03-08')    # => #<Date 2014-03-10>
bc.add_business_days Date.parse('2014-03-10'), 2    # => #<Date 2014-03-12>
bc.preceding_business_day Date.parse('2014-03-11')  # => #<Date 2014-03-10>
```

And in multi-value contexts, too!

```ruby
bc.add_business_day [ Date.parse('2014-03-10'), Date.parse('2014-03-11') ]
# => [ #<Date 2014-03-11>, #<Date 2014-03-12> ]
```

### Non-standard holidays

If you need a different list of holidays, you can skip the porcelain and create the calendar yourself with a custom holiday-determiner proc:

```ruby
holiday_tester = Proc.new { |date| MY_HOLIDAY_DATES.include? date }
bc = BusinessCalendar::Calendar.new(holiday_tester)
```

You can also create an API that returns a list of holidays, and point BusinessCalendar to the API.

The API needs to respond to an `HTTP GET` with status `200` and a JSON response with field `holidays` containing a list of ISO 8601 string dates:

```json
{
  "holidays": [
    "2018-10-08",
    "2018-11-12",
    "2018-11-22"
  ]
}
```

With this option, holiday dates are *temporarily* cached (with a default ttl of 300s). This is so that changes to the data being returned by the API will not necessitate restarting every application/process that uses BusinessCalendar with that API.

Usage:

```ruby
# additions = URI to hit for dates to be added to holiday list. Set to nil if none
# removals  = URI to hit for dates to be removed from holiday list. Set to nil if none
#
# opts      = Set same config options (regions, holiday_names, additions_only)
#             as the YAML files, with the additional option "ttl" to set ttl on
#             cached dates. Defaults to 300s.

bc = BusinessCalendar.for_endpoint('https://some.test/calendars/2018', 'https://some.test/calendars/2018_removals')
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
