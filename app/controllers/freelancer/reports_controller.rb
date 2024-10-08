require "csv"

class Freelancer::ReportsController < AuthenticatedController
  def index
  end

  def payments
    csv_data = CSV.generate(headers: true) do |csv|
      csv << ["Deposited", "Amount", "Fee", "Status", "Project", "Client", "Disbursed", "Received", "Total payout amount"]
      current_user.payments_received.includes(:disbursement_line, :payout_line).successful.find_each(order: :desc) do |p|
        payout_metadata = p.payout_line&.metadata
        payout_amount = payout_metadata&.dig("amount")
        csv << [
          p.paid_at,
          p.freelancer_amount,
          p.freelancer_fee,
          p.status,
          p.project,
          p.client,
          p.disbursement_line&.created_at,
          ActiveSupport::JSON.send(:convert_dates_from, payout_metadata&.dig("arrival_date")),
          payout_amount ? Money.new(payout_amount) : nil,
        ]
      end
    end
    send_data(csv_data, filename: "payments-#{Time.zone.today}.csv")
  end
end
