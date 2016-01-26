require 'coveralls'

Coveralls.wear! do
  add_filter "version.rb"
  add_filter "spec/"
end
