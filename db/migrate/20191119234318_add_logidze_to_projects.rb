class AddLogidzeToProjects < ActiveRecord::Migration[5.0]
  require "logidze/migration"

  def up
    add_column :projects, :log_data, :jsonb

    safety_assured do
      execute <<-SQL
        CREATE TRIGGER logidze_on_projects
        BEFORE UPDATE OR INSERT ON projects FOR EACH ROW
        WHEN (coalesce(current_setting('logidze.disabled', true), '') <> 'on')
        EXECUTE PROCEDURE logidze_logger(null, 'updated_at', '{id,created_at,updated_at}');
      SQL

      execute <<-SQL
        UPDATE projects as t
        SET log_data = logidze_snapshot(to_jsonb(t), 'updated_at', '{id,created_at,updated_at}');
      SQL
    end
  end

  def down
    safety_assured do
      execute "DROP TRIGGER IF EXISTS logidze_on_projects on projects;"
    end

    remove_column :projects, :log_data
  end
end
