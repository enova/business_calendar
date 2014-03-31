require 'bundler/setup'
Bundler.setup

require 'business_calendar'
require 'date'
require 'timecop'

# I'm not depending on ActiveSupport just for this.
class String
  def to_date
    Date.parse self
  end
end

class Date
  def inspect
    "#<Date #{strftime("%Y-%m-%d")}>"
  end
end
