class AddLogidzeToComments < ActiveRecord::Migration[5.0]
  require "logidze/migration"
  include Logidze::Migration

  def up
    add_column :comments, :log_data, :jsonb

    safety_assured do
      execute <<-SQL
        CREATE TRIGGER logidze_on_comments
        BEFORE UPDATE OR INSERT ON comments FOR EACH ROW
        WHEN (coalesce(#{current_setting("logidze.disabled")}, '') <> 'on')
        EXECUTE PROCEDURE logidze_logger(null, 'updated_at', '{id,created_at,updated_at}');
      SQL

      execute <<-SQL
        UPDATE comments as t
        SET log_data = logidze_snapshot(to_jsonb(t), 'updated_at', '{id,created_at,updated_at}');
      SQL
    end
  end

  def down
    safety_assured do
      execute "DROP TRIGGER IF EXISTS logidze_on_comments on comments;"
    end

    remove_column :comments, :log_data
  end
end
