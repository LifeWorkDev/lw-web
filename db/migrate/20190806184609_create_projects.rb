class CreateProjects < ActiveRecord::Migration[6.0]
  def change
    create_table :projects do |t|
      t.string :name
      t.monetize :amount
      t.string :type, null: false
      t.jsonb :metadata
      t.belongs_to :organization, null: false, foreign_key: true
      t.belongs_to :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :projects, :metadata, using: :gin
  end
end
