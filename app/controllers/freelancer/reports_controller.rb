require "csv"

class Freelancer::ReportsController < AuthenticatedController
  def index
  end

  def payments
    csv_data = CSV.generate(headers: true) do |csv|
      csv << ["Deposited", "Amount", "Status", "Project", "Client", "Disbursed", "Received", "Total payout amount"]
      current_user.payments.includes(:disbursement_line, :payout_line).successful.find_each do |p|
        csv << [
          p.paid_at,
          p.amount,
          p.status,
          p.project,
          p.client,
          p.disbursement_line.created_at,
          p.payout_line.metadata["arrival_date"],
          Money.new(p.payout_line.metadata["amount"]),
        ]
      end
    end
    send_data(csv_data, filename: "payments-#{Time.zone.today}.csv")
  end
end
