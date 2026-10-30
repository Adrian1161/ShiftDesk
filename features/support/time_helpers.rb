# Lets steps fix "today" with travel_to so date-based scenarios don't change over time.
World(ActiveSupport::Testing::TimeHelpers)

After do
  travel_back
end
