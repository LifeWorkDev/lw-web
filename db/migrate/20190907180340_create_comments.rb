class CreateComments < ActiveRecord::Migration[6.0]
  def change
    create_table :comments do |t|
      t.references :commentable, polymorphic: true
      t.references :commenter
      t.string :comment
      t.timestamp :read_at
      t.references :read_by

      t.timestamps
    end
  end
end
