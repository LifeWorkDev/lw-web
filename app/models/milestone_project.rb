class MilestoneProject < Project
  has_many :milestones, -> { order(:date) }, dependent: :destroy, foreign_key: :project_id, inverse_of: :project
  has_many :comments, through: :milestones
  has_many :payments, through: :milestones
  accepts_nested_attributes_for :milestones, reject_if: :existing_milestone?, allow_destroy: true

  ICON = mdi_url("flag-checkered").freeze
  NAME = "Milestone-based".freeze

  FOR_SELECT = {
    name: NAME,
    icon: ICON,
    description: "Set amounts, paid on specific dates".freeze,
  }.freeze

  def deposit!(user = nil)
    milestones.first.deposit!(user)
  end

  def milestones_changed?
    milestones.any? do |m|
      m.nilify_blanks # So that change from nil to '' isn't considered changed?
      m.new_record? || m.marked_for_destruction? || m.changed?
    end
  end

  def start_date
    milestones.first&.date
  end

private

  def existing_milestone?(milestone_attrs)
    return true if milestones.find_by(date: milestone_attrs[:date])

    false
  end
end
