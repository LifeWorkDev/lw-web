class AddFeesToPayments < ActiveRecord::Migration[6.0]
  def change
    add_column :payments, :platform_fee_cents, :integer, null: false, default: 0
    add_column :payments, :processing_fee_cents, :integer, null: false, default: 0
    add_column :payments, :client_pays_fees, :boolean, null: false, default: false

    reversible do |dir|
      dir.up do
        Payment.reset_column_information

        Payment.disbursed.each do |payment|
          payment.platform_fee = payment.platform_fee_line.amount - (payment.platform_refund_line&.amount || 0)
          payment.processing_fee = payment.processing_fee_line.amount - (payment.processing_refund_line&.amount || 0)
          payment.save!
        end

        Payment.where(status: %i[pending succeeded failed]).each do |payment|
          payment.platform_fee = payment.pays_for.platform_fee
          payment.processing_fee = payment.pays_for.processing_fee
          payment.save!
        end
      end
    end
  end
end
