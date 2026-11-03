class ScheduleWeek < ApplicationRecord
  belongs_to :business
  has_many :shifts, dependent: :destroy

  enum :status, { draft: "draft", published: "published" }, default: :draft, validate: true

  # Weeks always start on Monday, whichever day of the week was given.
  normalizes :week_start, with: ->(date) { date.beginning_of_week(:monday) }

  validates :week_start, presence: true, uniqueness: { scope: :business_id }

  def days
    week_start..(week_start + 6.days)
  end

  # Makes the week visible to employees. Returns false if it was already published.
  def publish
    return false if published?

    update(status: :published, published_at: Time.current)
  end

  def to_s
    "Week of #{week_start.strftime('%b %-d, %Y')}"
  end
end
