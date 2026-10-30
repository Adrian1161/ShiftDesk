class Shift < ApplicationRecord
  belongs_to :schedule_week
  belongs_to :membership, optional: true

  validates :starts_at, :ends_at, presence: true
  validate :ends_after_start

  scope :chronological, -> { order(:starts_at) }
  # Shifts that have not ended yet, including any in progress right now.
  scope :upcoming, -> { where(ends_at: Time.current..) }
  scope :published, -> { joins(:schedule_week).merge(ScheduleWeek.published) }

  private

  def ends_after_start
    return if starts_at.blank? || ends_at.blank?

    errors.add(:ends_at, "must be after the start time") if ends_at <= starts_at
  end
end
