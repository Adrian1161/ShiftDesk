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
end
