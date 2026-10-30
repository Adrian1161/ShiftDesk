class ScheduleWeeksController < ApplicationController
  before_action :require_login
  before_action :set_business
  before_action :set_schedule_week, only: [ :show, :publish ]
  before_action :require_schedule_manager, only: :publish

  def index
    @schedule_weeks = visible_schedule_weeks.order(week_start: :desc)
  end

  def show
    @shifts_by_day = @schedule_week.shifts
      .includes(membership: :user)
      .chronological
      .group_by { |shift| shift.starts_at.to_date }
  end

  def publish
    if @schedule_week.publish
      redirect_to [ @business, @schedule_week ], notice: "#{@schedule_week} is published. Employees can now see it."
    else
      redirect_to [ @business, @schedule_week ], alert: "#{@schedule_week} is already published."
    end
  end

  private

  # Employees only see published weeks; managers and owners also see drafts.
  def visible_schedule_weeks
    @membership.manages_schedule? ? @business.schedule_weeks : @business.schedule_weeks.published
  end

  def set_business
    @business = current_user.businesses.find(params[:business_id])
    @membership = @business.memberships.find_by!(user: current_user)
  end

  def set_schedule_week
    @schedule_week = visible_schedule_weeks.find(params[:id])
  end

  def require_schedule_manager
    head :forbidden unless @membership.manages_schedule?
  end
end
