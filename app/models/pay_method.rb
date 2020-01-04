class PayMethod < ApplicationRecord
  include Status

  belongs_to :org
  belongs_to :created_by, class_name: 'User'

  validates :last_4, numericality: { integer_only: true }
  validates :issuer, :kind, :stripe_id, presence: true

  def bank_account?
    false
  end

  def card?
    false
  end

  memoize def display_type
    model_name.human.titleize
  end

  memoize def expires
    "#{exp_month}/#{exp_year}" if exp_month.present? && exp_year.present?
  end

  memoize def expires_at
    Date.new(exp_year, exp_month) + 1.month
  end

  memoize def expired?
    expires_at <= Time.current
  end
end
