class CreatePayMethods < ActiveRecord::Migration[6.0]
  def change
    create_table :pay_methods do |t|
      t.string :type, null: false
      t.string :status, null: false
      t.citext :name
      t.citext :issuer
      t.citext :kind
      t.string :last_4
      t.integer :exp_month
      t.integer :exp_year
      t.belongs_to :org, null: false, foreign_key: true, index: false
      t.belongs_to :created_by, null: false, foreign_key: {to_table: :users}, index: false
      t.string :plaid_id
      t.string :plaid_token
      t.string :stripe_id, null: false

      t.timestamps
    end

    add_index :pay_methods, %i[org_id status type]
  end
end
