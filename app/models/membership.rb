class Membership < ApplicationRecord
  belongs_to :business
  belongs_to :user
  has_many :shifts, dependent: :nullify

  validates :role, inclusion: { in: %w[owner manager employee] }
  validates :user_id, uniqueness: { scope: :business_id }

  def manages_schedule?
    role.in?(%w[owner manager])
  end
end
