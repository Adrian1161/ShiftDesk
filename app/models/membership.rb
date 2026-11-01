class Membership < ApplicationRecord
  belongs_to :business
  belongs_to :user
  has_many :availabilities, dependent: :destroy # added as part of availability validation
  validates :role, inclusion: { in: %w[owner manager employee] }
  validates :user_id, uniqueness: { scope: :business_id }
end
