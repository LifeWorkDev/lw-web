module Dates
  extend ActiveSupport::Concern

  included do
    # Stripe cuts off ACH for the day at 21:00 UTC
    # https://stripe.com/docs/ach#ach-payments-workflow
    def deposit_time(deposit_date = nil)
      client.primary_contact.use_zone do
        deposit_date ||= Date.current
      end
      deposit_date.to_time(:utc).change(hour: 20, min: 45)
    end

    def payable?
      client.primary_contact.use_zone do
        date <= Date.current
      end
    end
    alias_method :disbursable?, :payable?

    def payment_date?
      client.primary_contact.use_zone do
        date == Date.current
      end
    end
    alias_method :disbursement_date?, :payment_date?

    def payment_time
      client.primary_contact.local_time(date).change(hour: 9)
    end
    alias_method :disbursement_time, :payment_time

    # 3 business days before Milestone date
    def reminder_date
      Business::Calendar.load_cached("achus").subtract_business_days(date, 3)
    end

    # 9am local time
    def reminder_time(user)
      user.local_time(reminder_date).change(hour: 9)
    end

    def client_reminder_time
      reminder_time(client.primary_contact)
    end

    def freelancer_reminder_time
      reminder_time(freelancer)
    end
  end
end
