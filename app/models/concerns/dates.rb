module Dates
  extend ActiveSupport::Concern

  included do
    # Stripe cuts off ACH for the day at 21:00 UTC
    # https://stripe.com/docs/ach#ach-payments-workflow
    memoize def deposit_time
      client.primary_contact.use_zone do
        Time.current.change(hour: 20, min: 45, zone: 'UTC')
      end
    end

    memoize def payment_date?
      freelancer.use_zone do
        date == Date.current
      end
    end

    memoize def payment_time
      client.primary_contact.local_time(date).change(hour: 9)
    end

    # 3 business days before Milestone date
    memoize def reminder_date
      Business::Calendar.load_cached('achus').subtract_business_days(date, 3)
    end

    # 9am local time
    def reminder_time(user)
      user.local_time(reminder_date).change(hour: 9)
    end

    memoize def client_reminder_time
      reminder_time(client.primary_contact)
    end

    memoize def freelancer_reminder_time
      reminder_time(freelancer)
    end
  end
end
