class UpdateLogidzeForProjects < ActiveRecord::Migration[5.0]
  def change
    reversible do |dir|
      dir.up do
        safety_assured do
          execute "DROP TRIGGER IF EXISTS logidze_on_projects on projects;"

          execute <<~SQL
            CREATE TRIGGER logidze_on_projects
            BEFORE UPDATE OR INSERT ON projects FOR EACH ROW
            WHEN (coalesce(current_setting('logidze.disabled', true), '') <> 'on')
            -- Parameters: history_size_limit (integer), timestamp_column (text), filtered_columns (text[]),
            -- include_columns (boolean), debounce_time_ms (integer)
            EXECUTE PROCEDURE logidze_logger(null, 'updated_at', '{id,created_at,updated_at}');

          SQL
        end
      end

      dir.down do
        # NOTE: We have no idea on how to revert the migration
        # ('cause we don't know the previous trigger params),
        # but you can do that on your own.
        #
        # Uncomment this line if you want to raise an error.
        # raise ActiveRecord::IrreversibleMigration
      end
    end
  end
end
