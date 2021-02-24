class AddFeesToPayments < ActiveRecord::Migration[6.0]
  def change
    add_column :payments, :platform_fee_cents, :integer, null: false, default: 0
    add_column :payments, :processing_fee_cents, :integer, null: false, default: 0
    add_column :payments, :client_pays_fees, :boolean, null: false, default: false

    reversible do |dir|
      dir.up do
        Payment.reset_column_information

        Payment.disbursed.each do |payment|
          payment.platform_fee_cents = payment.lines.credits.where(code: :platform).sum(:amount) - payment.lines.credits.where(code: :platform_refund).sum(:amount)
          payment.processing_fee_cents = payment.lines.credits.where(code: :processing).sum(:amount) - payment.lines.credits.where(code: :processing_refund).sum(:amount)
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
