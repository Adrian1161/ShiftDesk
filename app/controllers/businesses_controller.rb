class BusinessesController < ApplicationController
  before_action :require_login, only: :show

  def new
    redirect_to business_path(current_user.businesses.first) and return if current_user&.businesses&.exists?

    @business = Business.new
  end

  def create
    if current_user
      redirect_to business_path(current_user.businesses.first), alert: "Sign out before registering a new business."
      return
    end

    @business = Business.new(name: params.dig(:business, :name))
    @user = User.new(owner_params)

    if @business.valid? && @user.valid?
      ActiveRecord::Base.transaction do
        @user.save!
        @business.save!
        Membership.create!(user: @user, business: @business, role: "owner")
      end
      reset_session
      session[:user_id] = @user.id
      redirect_to @business, notice: "Your business is ready."
    else
      render :new, status: :unprocessable_content
    end
  end

  def show
    @business = current_user.businesses.find(params[:id])
  end

  private

  def owner_params
    params.require(:business).permit(:owner_name, :email, :password, :password_confirmation)
          .to_h.transform_keys { |key| key == "owner_name" ? "name" : key }
  end
end
