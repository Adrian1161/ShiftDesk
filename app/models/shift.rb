class Shift < ApplicationRecord
    belongs_to :schedule_week
    belongs_to :membership, optional: true

    validates :starts_at, :ends_at, presence: true
    validate :ends_after_start
    validate :no_shift_overlap

    scope :chronological, -> { order(:starts_at) }
    scope :upcoming, -> { where(ends_at: Time.current..) }
    scope :published, -> { joins(:schedule_week).merge(ScheduleWeek.published) }

    private

    def ends_after_start
        return if starts_at.blank? || ends_at.blank?

        errors.add(:ends_at, "must be after the start time") if ends_at <= starts_at
    end

    def no_shift_overlap
        return unless membership_id && starts_at && ends_at

        overlap = Shift.where(membership_id: membership_id)
                       .where("starts_at < ? AND ends_at > ?", ends_at, starts_at)
        overlap = overlap.where.not(id: id) if persisted?

        if overlap.exists?
            errors.add(:base, "This employee has an overlapping shift in this time window.")
        end
    end
end
