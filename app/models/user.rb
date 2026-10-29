class User < ApplicationRecord
  has_secure_password

  has_many :memberships, dependent: :destroy
  has_many :businesses, through: :memberships

  before_validation { self.email = email.to_s.strip.downcase }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
end
