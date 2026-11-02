class TimeOffRequest < ApplicationRecord
  belongs_to :membership

  validates :start_date, :end_date, presence: true

  validate :dates_cannot_be_in_the_past
  validate :end_date_cannot_be_before_start_date

  private

  def dates_cannot_be_in_the_past
    if start_date.present? && start_date < Date.current
      errors.add(:start_date, "cannot be in the past")
    end

    if end_date.present? && end_date < Date.current
      errors.add(:end_date, "cannot be in the past")
    end
  end

  def end_date_cannot_be_before_start_date
    return if start_date.blank? || end_date.blank?

    if end_date < start_date
      errors.add(:end_date, "cannot be before the start date")
    end
  end
end
