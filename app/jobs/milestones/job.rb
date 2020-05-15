class Milestones::Job < ApplicationJob
  def perform(milestone)
    raise "Not a milestone" unless milestone.is_a? Milestone
  end
end
