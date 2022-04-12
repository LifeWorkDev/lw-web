class UpdateQueTablesToVersion5 < ActiveRecord::Migration[7.0]
  def up
    Que.migrate!(version: 5)
    add_column :que_finished, :job_schema_version, :integer, default: 1
  end

  def down
    Que.migrate!(version: 4)
    remove_column :que_finished, :job_schema_version
  end
end
