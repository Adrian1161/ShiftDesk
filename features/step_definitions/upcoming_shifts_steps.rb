Given("today is {string}") do |date_and_time|
  travel_to Time.zone.parse(date_and_time)
end
