class UpcomingShiftsController < ApplicationController
  before_action :require_login

  def show
    @business = current_user.businesses.find(params[:business_id])
    membership = @business.memberships.find_by!(user: current_user)
    @shifts = membership.shifts.published.upcoming.chronological
  end
end
