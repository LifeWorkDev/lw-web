class AddRecipientAndPaidByToPayments < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    safety_assured { rename_column :payments, :user_id, :paid_by_id }
    add_reference :payments, :recipient, index: {algorithm: :concurrently}

    reversible do |dir|
      dir.up do
        Payment.includes(:pays_for).find_each do |payment|
          payment.update(recipient: payment.freelancer)
        end
      end
    end
  end
end
