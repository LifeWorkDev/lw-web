class CreateMilestones < ActiveRecord::Migration[6.0]
  def change
    create_table :milestones do |t|
      t.belongs_to :project, index: false, null: false, foreign_key: true
      t.datetime :date, null: false
      t.string   :status, null: false
      t.integer :amount_cents
      t.citext :description

      t.timestamps
    end

    add_index :milestones, %i[project_id date]
  end
end
