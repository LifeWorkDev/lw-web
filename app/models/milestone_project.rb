class MilestoneProject < Project
  has_many :milestones, -> { order(:date) }, dependent: :destroy, foreign_key: :project_id, inverse_of: :project
  has_many :comments, through: :milestones
  accepts_nested_attributes_for :milestones, reject_if: :existing_milestone

private

  def existing_milestone(milestone_attrs)
    return true if milestones.find_by(date: milestone_attrs[:date])

    false
  end
end
