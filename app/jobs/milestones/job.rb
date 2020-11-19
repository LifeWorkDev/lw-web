class Milestones::Job < ApplicationJob
  def perform(milestone)
    raise "Not a valid milestone" unless milestone.is_a?(Milestone) && milestone.project.is_a?(MilestoneProject)
  end
end
