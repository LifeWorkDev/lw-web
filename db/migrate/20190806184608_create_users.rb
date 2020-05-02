class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.citext :name
      t.citext :email, null: false, index: { unique: true }

      t.string :status, null: false, index: true
      t.jsonb  :roles, null: false, default: []

      t.citext :phone
      t.citext :address
      t.string :time_zone
      t.belongs_to :org, foreign_key: true
      t.jsonb :metadata

      ## Invitable
      t.integer  :invited_by_id
      t.string   :invited_by_type
      t.string   :invitation_token, index: { unique: true }
      t.datetime :invitation_created_at
      t.datetime :invitation_sent_at
      t.datetime :invitation_accepted_at
      t.integer  :invitation_limit

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet     :current_sign_in_ip
      t.inet     :last_sign_in_ip

      ## Database authenticatable
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token, index: { unique: true }
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Confirmable
      t.string   :confirmation_token, index: { unique: true }
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.citext   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      t.integer  :failed_attempts, default: 0, null: false
      t.string   :unlock_token, index: { unique: true }
      t.datetime :locked_at

      t.string :stripe_id
      t.string :stripe_key
      t.string :stripe_access_token
      t.string :stripe_refresh_token

      t.timestamps null: false
    end

    add_index :users, :metadata, using: :gin
    add_index :users, :roles, using: :gin
  end
end
