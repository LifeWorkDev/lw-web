require "csv"

class Freelancer::ReportsController < AuthenticatedController
  def index
  end

  def payments
    csv_data = CSV.generate(headers: true) do |csv|
      csv << %w[Date Amount Project Client]
      current_user.received_payments.find_each do |p|
        csv << [
          p.scheduled_for || p.pays_for.date,
          p.amount,
          p.project,
          p.client,
        ]
      end
    end
    send_data(csv_data, filename: "payments-#{Time.zone.today}.csv")
  end
end
