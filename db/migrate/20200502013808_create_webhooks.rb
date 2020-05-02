class CreateWebhooks < ActiveRecord::Migration[6.0]
  def change
    create_table :webhooks do |t|
      t.string :source, null: false
      t.string :status, null: false
      t.string :event
      t.jsonb :headers, null: false
      t.jsonb :data

      t.timestamps
    end
  end
end
