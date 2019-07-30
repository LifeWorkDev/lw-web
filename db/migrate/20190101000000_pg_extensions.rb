class PgExtensions < ActiveRecord::Migration[5.2]
  def change
    %w[citext fuzzystrmatch pgcrypto plpgsql pg_stat_statements].each do |ext|
      enable_extension ext unless extension_enabled?(ext)
    end
  end
end
