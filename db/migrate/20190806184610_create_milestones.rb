class CreateMilestones < ActiveRecord::Migration[6.0]
  def change
    create_table :milestones do |t|
      t.datetime :date, null: false
      t.monetize :amount, currency: { present: false }
      t.string :description
      t.belongs_to :project, index: false, null: false, foreign_key: true

      t.timestamps
    end

    add_index :milestones, %i[project_id date]
  end
end
