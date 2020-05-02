class CreateProjects < ActiveRecord::Migration[6.0]
  def change
    create_table :projects do |t|
      t.belongs_to :org, null: false, foreign_key: true
      t.belongs_to :user, null: false, foreign_key: true, index: false
      t.citext :name, null: false
      t.string :status, null: false
      t.string :type, null: false
      t.integer :amount_cents
      t.string  :currency, null: false, default: "USD"
      t.string :slug, null: false
      t.jsonb :metadata

      t.timestamps
    end

    add_index :projects, :metadata, using: :gin
    add_index :projects, %i[user_id slug], unique: true
  end
end
