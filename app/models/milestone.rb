class Milestone < ApplicationRecord
  belongs_to :project, class_name: 'MilestoneProject'
end
