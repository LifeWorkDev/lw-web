class UpdateProjectStatuses < ActiveRecord::Migration[6.0]
  def up
    initial = Project.aasm.initial_state
    Project.where(status: :pending).update_all(status: initial)
  end
end
