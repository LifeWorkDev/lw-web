class AddRecipientForeignKeyToPayments < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      add_foreign_key :payments, :users, column: :recipient_id
      change_column_null :payments, :recipient_id, false
    end
  end
end
