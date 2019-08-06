class CreateOrganizations < ActiveRecord::Migration[6.0]
  def change
    create_table :organizations do |t|
      t.string :name
      t.jsonb  :metadata

      t.timestamps
    end

    add_index :organizations, :metadata, using: :gin
  end
end
