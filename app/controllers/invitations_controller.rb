class InvitationsController < ApplicationController
  before_action :require_login, only: [ :new, :create ]
  before_action :set_owner_business, only: [ :new, :create ]

  def new
    @invitation = @business.invitations.new
  end

  def create
    @invitation = @business.invitations.new(email: params.dig(:invitation, :email))
    @invitation.invited_by = current_user

    if @invitation.save
      InvitationMailer.with(invitation: @invitation).invite.deliver_now
      message = ENV["SMTP_HOST"].present? ? "Invitation sent to #{@invitation.email}." :
        "Invitation created for #{@invitation.email}. Configure SMTP to send email."
      redirect_to @business, notice: message
    else
      render :new, status: :unprocessable_content
    end
  end

  def accept
    @invitation = find_invitation
    return render_invalid_invitation unless @invitation

    @existing_user = User.exists?(email: @invitation.email)
  end

  def join
    @invitation = find_invitation
    return render_invalid_invitation unless @invitation

    @existing_user = User.exists?(email: @invitation.email)
    user = User.find_by(email: @invitation.email)
    if user
      unless user.authenticate(params[:password])
        @error = "Incorrect password."
        return render :accept, status: :unprocessable_content
      end
    else
      user = User.new(name: params[:name], email: @invitation.email,
                      password: params[:password], password_confirmation: params[:password_confirmation])
      unless user.valid?
        @error = user.errors.full_messages.to_sentence
        return render :accept, status: :unprocessable_content
      end
    end

    ActiveRecord::Base.transaction do
      @invitation.lock!
      raise ActiveRecord::RecordInvalid, @invitation if @invitation.accepted?

      user.save! if user.new_record?
      Membership.find_or_create_by!(business: @invitation.business, user: user) do |membership|
        membership.role = "employee"
      end
      @invitation.update!(accepted_at: Time.current)
    end

    reset_session
    session[:user_id] = user.id
    redirect_to @invitation.business, notice: "You joined #{@invitation.business.name}."
  rescue ActiveRecord::RecordInvalid
    render_invalid_invitation
  end

  private

  def set_owner_business
    @business = current_user&.businesses&.find_by(id: params[:business_id])
    return head :not_found unless @business

    head :forbidden unless @business.memberships.exists?(user: current_user, role: "owner")
  end

  def find_invitation
    invitation = Invitation.find_signed(params[:token], purpose: :join)
    invitation unless invitation&.accepted?
  end

  def render_invalid_invitation
    render plain: "This invitation is invalid or has already been used.", status: :gone
  end
end
