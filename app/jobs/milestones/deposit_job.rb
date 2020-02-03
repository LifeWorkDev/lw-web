class Milestones::DepositJob < ApplicationJob
  def perform(milestone)
    milestone.deposit!
  end
end
