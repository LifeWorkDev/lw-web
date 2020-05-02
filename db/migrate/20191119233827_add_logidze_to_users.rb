class AddLogidzeToUsers < ActiveRecord::Migration[5.0]
  require "logidze/migration"
  include Logidze::Migration

  def up
    add_column :users, :log_data, :jsonb

    safety_assured do
      execute <<-SQL
        CREATE TRIGGER logidze_on_users
        BEFORE UPDATE OR INSERT ON users FOR EACH ROW
        WHEN (coalesce(#{current_setting('logidze.disabled')}, '') <> 'on')
        EXECUTE PROCEDURE logidze_logger(null, 'updated_at', '{id,created_at,updated_at,sign_in_count,reset_password_token,reset_password_sent_at,remember_created_at,current_sign_in_at,last_sign_in_at,current_sign_in_ip,last_sign_in_ip,failed_attempts,unlock_token,locked_at,invitation_token,invitation_created_at,invitation_sent_at,invitation_accepted_at,invitation_limit,invited_by_type,invited_by_id,invitations_count,encrypted_password,unconfirmed_email,confirmation_token,confirmation_sent_at,confirmed_at}');
      SQL

      execute <<-SQL
        UPDATE users as t
        SET log_data = logidze_snapshot(to_jsonb(t), 'updated_at', '{id,created_at,updated_at,sign_in_count,reset_password_token,reset_password_sent_at,remember_created_at,current_sign_in_at,last_sign_in_at,current_sign_in_ip,last_sign_in_ip,failed_attempts,unlock_token,locked_at,invitation_token,invitation_created_at,invitation_sent_at,invitation_accepted_at,invitation_limit,invited_by_type,invited_by_id,invitations_count,encrypted_password,unconfirmed_email,confirmation_token,confirmation_sent_at,confirmed_at}');
      SQL
    end
  end

  def down
    safety_assured do
      execute "DROP TRIGGER IF EXISTS logidze_on_users on users;"
    end

    remove_column :users, :log_data
  end
end
