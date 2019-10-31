class PayMethod < ApplicationRecord
  include Status

  belongs_to :org
  belongs_to :created_by, class_name: 'User'

  validates :last_4, numericality: { integer_only: true }
  validates :issuer, :kind, :stripe_id, presence: true

  def display_type
    model_name.human.titleize
  end

  memoize def stripe_obj
    Stripe::Source.retrieve(stripe_id)
  end
end
