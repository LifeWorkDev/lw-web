class Date
  def safe_change_day(day)
    change(day: day)
  rescue Date::Error # Tried to set a day that doesn't exist, ex: Feb 31
    end_of_month
  end
end
