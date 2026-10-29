class Invitation < ApplicationRecord
  belongs_to :business
  belongs_to :invited_by, class_name: "User"

  before_validation { self.email = email.to_s.strip.downcase }

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :email_is_not_already_a_member, on: :create

  def accepted?
    accepted_at.present?
  end

  private

  def email_is_not_already_a_member
    return if email.blank? || business.blank?

    errors.add(:email, "already belongs to this business") if business.users.exists?(email: email)
  end
end
