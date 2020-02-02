class AddEmailOptInToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :email_opt_in, :boolean, null: false, default: true
  end
end
