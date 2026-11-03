class TimeOffRequestsController < ApplicationController
  before_action :require_login
  before_action :load_memberships, only: [ :new, :create ]
  # loads the current user's memberships with their associated businesses
  def new
    @time_off_request = TimeOffRequest.new
  end

  def create
    membership = current_user.memberships.find_by(id: request_params[:membership_id])
    # creates a new time-off request
    @time_off_request = TimeOffRequest.new(
      start_date: request_params[:start_date],
      end_date: request_params[:end_date],
      membership: membership
    )
    # confirms that the time-off request was saved
    if @time_off_request.save
      redirect_to membership.business, notice: "Time-off request submitted."
    else
      render :new, status: :unprocessable_content
    end
  end

  private
  # loads the current user's memberships with their associated businesses
  def load_memberships
    @memberships = current_user.memberships.includes(:business)
  end
  # it is defining what elements are allowed to be submitted in the request
  def request_params
    params.require(:time_off_request).permit(:membership_id, :start_date, :end_date)
  end
end
