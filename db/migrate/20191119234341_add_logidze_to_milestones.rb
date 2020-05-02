class AddLogidzeToMilestones < ActiveRecord::Migration[5.0]
  require "logidze/migration"
  include Logidze::Migration

  def up
    add_column :milestones, :log_data, :jsonb

    safety_assured do
      execute <<-SQL
        CREATE TRIGGER logidze_on_milestones
        BEFORE UPDATE OR INSERT ON milestones FOR EACH ROW
        WHEN (coalesce(#{current_setting('logidze.disabled')}, '') <> 'on')
        EXECUTE PROCEDURE logidze_logger(null, 'updated_at', '{id,created_at,updated_at}');
      SQL

      execute <<-SQL
        UPDATE milestones as t
        SET log_data = logidze_snapshot(to_jsonb(t), 'updated_at', '{id,created_at,updated_at}');
      SQL
    end
  end

  def down
    safety_assured do
      execute "DROP TRIGGER IF EXISTS logidze_on_milestones on milestones;"
    end

    remove_column :milestones, :log_data
  end
end
