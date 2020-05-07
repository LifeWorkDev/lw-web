class CreateOrgs < ActiveRecord::Migration[6.0]
  def change
    create_table :orgs do |t|
      t.citext :name
      t.string :status, null: false
      t.string :slug, null: false, index: {unique: true}
      t.jsonb :metadata
      t.string :stripe_id

      t.timestamps
    end

    add_index :orgs, :metadata, using: :gin
  end
end
