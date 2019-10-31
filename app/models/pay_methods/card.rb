class PayMethods::Card < PayMethod
  before_validation :associate_with_stripe_customer!, on: :create

  validates :exp_month, :exp_year, numericality: { integer_only: true }

  def update_from_stripe!
    update_from_stripe_object!(stripe_obj)
  end

  def update_from_stripe_object!(stripe_object)
    card = stripe_object.card
    owner = stripe_object.owner
    update!(exp_month: card.exp_month, exp_year: card.exp_year, last_digits: card.last4, postal_code: owner&.address&.postal_code)
  end

private

  def associate_with_stripe_customer!
    if org.stripe_id.present?
      org.stripe_obj.sources.create(source: stripe_id)
    else
      customer = Stripe::Customer.create(
        name: org.display_name,
        email: org.primary_contact&.email,
        source: stripe_id,
        metadata: {
          'Org ID': org.id,
        },
      )
      org.update_columns(stripe_id: customer.id) # rubocop:disable Rails/SkipsModelValidations
    end
  rescue Stripe::StripeError => e
    errors.add(:stripe_id, e.message)
  end
end
