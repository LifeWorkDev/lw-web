class UpdateLogidzeForUsers < ActiveRecord::Migration[5.0]
  def change
    reversible do |dir|
      dir.up do
        safety_assured do
          execute "DROP TRIGGER IF EXISTS logidze_on_users on users;"

          execute <<~SQL
            CREATE TRIGGER logidze_on_users
            BEFORE UPDATE OR INSERT ON users FOR EACH ROW
            WHEN (coalesce(current_setting('logidze.disabled', true), '') <> 'on')
            -- Parameters: history_size_limit (integer), timestamp_column (text), filtered_columns (text[]),
            -- include_columns (boolean), debounce_time_ms (integer)
            EXECUTE PROCEDURE logidze_logger(null, 'updated_at', '{id,created_at,updated_at,sign_in_count,reset_password_token,reset_password_sent_at,remember_created_at,current_sign_in_at,last_sign_in_at,current_sign_in_ip,last_sign_in_ip,failed_attempts,unlock_token,locked_at,invitation_token,invitation_created_at,invitation_sent_at,invitation_accepted_at,invitation_limit,invited_by_type,invited_by_id,invitations_count,encrypted_password,unconfirmed_email,confirmation_token,confirmation_sent_at,confirmed_at}');

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
