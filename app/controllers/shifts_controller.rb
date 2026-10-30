
class ShiftsController < ApplicationController
  before_action :require_login
  before_action :set_business
  before_action :set_schedule_week

  def new
    @shift = @schedule_week.shifts.new
    @memberships = @business.memberships
  end

  def create
    date = params[:date]

    start_datetime = Time.zone.parse("#{date} #{params[:start_time]}")
    end_datetime = Time.zone.parse("#{date} #{params[:end_time]}")

    @shift = @schedule_week.shifts.new(
      starts_at: start_datetime,
      ends_at: end_datetime,
      membership_id: params[:shift][:membership_id]
    )

    if @shift.save
      redirect_to [@business, @schedule_week], notice: "Shift created successfully."
    else
      @memberships = @business.memberships
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_business
    @business = current_user.businesses.find(params[:business_id])
  end

  def set_schedule_week
    @schedule_week = @business.schedule_weeks.find(params[:schedule_week_id])
  end
end
