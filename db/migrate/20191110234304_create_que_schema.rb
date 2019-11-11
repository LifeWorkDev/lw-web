class CreateQueSchema < ActiveRecord::Migration[6.0]
  def up
    Que.migrate!(version: 4)

    safety_assured do
      execute <<-SQL
        CREATE TABLE que_finished AS SELECT * FROM que_jobs LIMIT 0;

        CREATE FUNCTION que_save_finished()
        RETURNS trigger
        LANGUAGE plpgsql
        AS $$
          BEGIN
            OLD.finished_at = current_timestamp;
            INSERT INTO que_finished SELECT OLD.*;
            RETURN OLD;
          END;
        $$;

        CREATE TRIGGER que_save_finished_on_delete BEFORE DELETE ON que_jobs FOR EACH ROW EXECUTE PROCEDURE que_save_finished();
      SQL
    end
  end

  def down
    safety_assured do
      execute <<-SQL
        DROP TRIGGER que_save_finished_on_delete ON que_jobs;
        DROP FUNCTION que_save_finished;
        DROP TABLE que_finished;
      SQL
    end

    # Migrate to version 0 to remove Que entirely.
    Que.migrate!(version: 0)
  end
end
