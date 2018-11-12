require 'bundler/setup'
Bundler.setup

require 'simplecov'

require 'business_calendar'
require 'date'
require 'webmock/rspec'
require 'pry'

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

RSpec.configure do |config|
  config.before do
    WebMock.disable_net_connect!
  end
end
