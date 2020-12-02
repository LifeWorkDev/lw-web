class AddLogidzeToOrgs < ActiveRecord::Migration[5.0]
  require "logidze/migration"

  def up
    add_column :orgs, :log_data, :jsonb

    safety_assured do
      execute <<-SQL
        CREATE TRIGGER logidze_on_orgs
        BEFORE UPDATE OR INSERT ON orgs FOR EACH ROW
        WHEN (coalesce(current_setting('logidze.disabled', true), '') <> 'on')
        EXECUTE PROCEDURE logidze_logger(null, 'updated_at', '{id,created_at,updated_at}');
      SQL

      execute <<-SQL
        UPDATE orgs as t
        SET log_data = logidze_snapshot(to_jsonb(t), 'updated_at', '{id,created_at,updated_at}');
      SQL
    end
  end

  def down
    safety_assured do
      execute "DROP TRIGGER IF EXISTS logidze_on_orgs on orgs;"
    end

    remove_column :orgs, :log_data
  end
end
