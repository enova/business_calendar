module BusinessCalendar::Shim
  def saturday?
    wday == 6
  end

  def sunday?
    wday == 0
  end
end

unless Date.method_defined?(:saturday?)
  Date.send(:include, BusinessCalendar::Shim)
end
