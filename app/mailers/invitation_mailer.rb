class InvitationMailer < ApplicationMailer
  def invite
    @invitation = params[:invitation]
    @accept_url = accept_invitation_url(
      token: @invitation.signed_id(purpose: :join, expires_in: 7.days),
      host: ENV.fetch("APP_HOST", "localhost:3000"),
      protocol: Rails.env.production? ? "https" : "http"
    )
    mail(to: @invitation.email, subject: "Join #{@invitation.business.name} on ShiftDesk")
  end
end
