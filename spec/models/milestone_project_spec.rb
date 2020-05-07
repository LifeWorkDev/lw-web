require "rails_helper"

RSpec.describe MilestoneProject, type: :model do
  subject(:project) { Fabricate(:milestone_project) }

  describe "accepts_nested_attributes_for :milestones" do
    subject(:project) { Fabricate(:milestone_project_with_milestones) }

    it "doesn't create multiple milestones for the same date" do
      Time.use_zone(ActiveSupport::TimeZone.basic_us_zones.sample) do
        milestone_attrs = project.milestones.collect { |m| {date: m.date.to_s} }
        expect { project.update(milestones_attributes: milestone_attrs) }.to not_change(Milestone, :count)
      end
    end
  end
end
