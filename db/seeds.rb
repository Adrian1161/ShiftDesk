# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Demo data for trying out schedules in development. Every demo account's password is "password123".
if Rails.env.development?
  business = Business.find_or_create_by!(name: "Corner Cafe")

  members = {
    "Alex Owner" => "owner",
    "Morgan Manager" => "manager",
    "Sam Employee" => "employee"
  }.to_h do |name, role|
    user = User.find_or_create_by!(email: "#{name.split.last.downcase}@example.com") do |new_user|
      new_user.name = name
      new_user.password = "password123"
    end
    [ role, business.memberships.find_or_create_by!(user: user) { |membership| membership.role = role } ]
  end

  week = business.schedule_weeks.find_or_create_by!(week_start: Date.current.next_week)
  if week.shifts.none?
    week.days.first(5).each do |day|
      week.shifts.create!(membership: members["employee"], starts_at: day.in_time_zone.change(hour: 9),
                          ends_at: day.in_time_zone.change(hour: 17))
    end
  end

  puts "Seeded #{business.name}. Sign in as manager@example.com or employee@example.com (password123)."
end
