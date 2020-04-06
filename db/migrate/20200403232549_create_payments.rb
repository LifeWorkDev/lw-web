class CreatePayments < ActiveRecord::Migration[6.0]
  def change
    create_table :payments do |t|
      t.integer :amount_cents, null: false, default: 0
      t.string :currency, null: false, default: 'USD'
      t.string :status, null: false
      t.datetime :scheduled_for
      t.datetime :paid_at
      t.citext :note
      t.string :stripe_id
      t.integer :stripe_fee_cents, null: false, default: 0
      t.string :stripe_fee_currency, null: false, default: 'USD'
      t.jsonb :metadata
      t.belongs_to :pays_for, polymorphic: true, null: false
      t.belongs_to :pay_method, null: false, foreign_key: true, index: false
      t.belongs_to :user, foreign_key: true, index: false

      t.timestamps
    end
  end
end
