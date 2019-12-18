class MoveActiveMilestonesToPending < ActiveRecord::Migration[6.0]
  def up
    Milestone.where(status: :active).update_all(status: :pending)
  end
end
