class Shift < ApplicationRecord
    belongs_to :employee
    belongs_to :business

    validates :start_time, :end_time, presence: true
    validate :no_shift_overlap

    private

    def no_shift_overlap
        return unless employee_id && start_time && end_time

        overlap = Shift.where(employee_id: employee_id).where("start_time < ? AND end_time > ?", end_time, start_time)

        overlap = overlap.where.not(id: id) if persisted?

        if overlap.exists?
            errors.add(:base, "This employee has an overlapping shift in this time window.")
        end
    end
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
