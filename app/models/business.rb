class Business < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :invitations, dependent: :destroy
  has_many :employees, dependent: :destroy

  validates :name, presence: true
end
