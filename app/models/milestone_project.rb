class MilestoneProject < Project
  has_many :milestones, dependent: :destroy, foreign_key: :project_id, inverse_of: :project
  accepts_nested_attributes_for :milestones
end
