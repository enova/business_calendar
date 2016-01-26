unless RUBY_VERSION == "1.8.7"
  require 'coveralls'

  Coveralls.wear! do
    add_filter "version.rb"
    add_filter "spec/"
  end
end
