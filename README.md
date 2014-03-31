# BusinessCalendar

Need to know what days you can actually debit a customer on in excruciating detail? Fed up with singleton-based gems 
that can't handle your complex, multi-international special needs? *So* over extending core objects like Numeric
and Date just to make your code a little cleaner? Well, do I have the gem for you! **BusinessCalendar** is a
reasonably light-weight solution, concerned primarily with banking holidays in different countries.

## Installation

Add this line to your application's Gemfile:

    gem 'business_calendar'

And then execute:

    $ bundle

## Usage

### Basic usage

Instantiate a calendar object with:

    bc = BusinessCalendar.for(:US)
    
This will automatically load holidays based on the US banking holiday schedule, as configured in `data/holidays.yml`. 
Currently, this gem supports `:GB` and `:US` regions.

Now, you can use it:

    bc.is_business_day? Date.parse('2014-03-10')        # => true
    bc.add_business_day Date.parse('2014-03-10')        # => #<Date 2014-03-11>
    bc.nearest_business_day Date.parse('2014-03-08')    # => #<Date 2014-03-10>
    bc.add_business_days Date.parse('2014-03-10'), 2    # => #<Date 2014-03-12>
    bc.preceding_business_day Date.parse('2014-03-11')  # => #<Date 2014-03-10>

And in multi-value contexts, too!

    bc.add_business_day [ Date.parse('2014-03-10'), Date.parse('2014-03-11') ]
    # => [ #<Date 2014-03-11>, #<Date 2014-03-12> ]

### Non-standard holidays

If you need a different list of holidays, you can skip the porcelain and create the calendar yourself with a custom holiday-determiner proc:

    holiday_tester = Proc.new { |date| MY_HOLIDAY_DATES.include? date }
    bc = BusinessCalendar::Calendar.new(holiday_tester)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
