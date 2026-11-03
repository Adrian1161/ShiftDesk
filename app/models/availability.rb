class Availability < ApplicationRecord
  belongs_to :membership

  validates :day_of_week, inclusion: { in: 0..6 }
  validates :start_time, :end_time, presence: true

  validate :end_time_after_start_time
  validate :no_overlapping_windows

  private

  def end_time_after_start_time
    return if start_time.blank? || end_time.blank?

    if end_time <= start_time
      errors.add(:end_time, "must be after the start time")
    end
  end

  def no_overlapping_windows
    return if membership_id.blank? || day_of_week.nil?
    return if start_time.blank? || end_time.blank? || end_time <= start_time

    overlapping = Availability.where(
      membership_id: membership_id,
      day_of_week: day_of_week
    ).where("start_time < ? AND end_time > ?", end_time, start_time)

    # When editing an existing window, don't compare it against itself.
    overlapping = overlapping.where.not(id: id) if persisted?

    if overlapping.exists?
      errors.add(:base, "This availability overlaps an existing window")
    end
  end
end
