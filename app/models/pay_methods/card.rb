class PayMethods::Card < PayMethod
  before_validation :associate_with_stripe_customer!, on: :create

  validates :exp_month, :exp_year, numericality: { integer_only: true }

  def card?
    true
  end

  def charge!(amount:, idempotency_key: '', metadata: {})
    Stripe::PaymentIntent.create({
                                   amount: amount.cents,
                                   currency: amount.currency.to_s,
                                   customer: org.stripe_id,
                                   payment_method: stripe_id,
                                   off_session: true,
                                   confirm: true,
                                   metadata: metadata,
                                 }, idempotency_key: "#{idempotency_key}-pay-method-#{id}")
  end

  memoize def stripe_obj
    Stripe::PaymentMethod.retrieve(stripe_id)
  end

  def to_s
    "#{issuer.titleize} #{kind.downcase} card ending in #{last_4}"
  end

  def update_from_stripe!
    update_from_stripe_object!(stripe_obj)
  end

  def update_from_stripe_object!(stripe_object)
    card = stripe_object.card
    owner = stripe_object.owner
    update!(exp_month: card.exp_month, exp_year: card.exp_year, last_4: card.last4, postal_code: owner&.address&.postal_code)
  end

private

  def associate_with_stripe_customer!
    if org.stripe_id.present?
      Stripe::PaymentMethod.attach(stripe_id, customer: org.stripe_id)
    else
      customer = Stripe::Customer.create(
        name: org.display_name,
        email: org.primary_contact&.email,
        payment_method: stripe_id,
        metadata: {
          'Org ID': org.id,
        },
      )
      if org.persisted?
        org.update_columns(stripe_id: customer.id) # rubocop:disable Rails/SkipsModelValidations
      else
        org.stripe_id = customer.id
      end
    end
    card = stripe_obj.card
    self.exp_month = card.exp_month
    self.exp_year = card.exp_year
    self.issuer = card.brand
    self.kind = card.funding
    self.last_4 = card.last4
  rescue Stripe::StripeError => e
    errors.add(:stripe_id, e.message)
  end
end
