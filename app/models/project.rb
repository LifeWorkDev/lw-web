class Project < ApplicationRecord
  has_logidze
  include Fees
  include Projects::Status
  include STIPreload
  extend FriendlyId
  friendly_id :name, use: :scoped, scope: :user_id

  belongs_to :client, class_name: "Org", foreign_key: :org_id, inverse_of: :projects
  has_many :client_users, through: :client, source: :users
  belongs_to :freelancer, class_name: "User", foreign_key: :user_id, inverse_of: :projects

  before_validation :set_defaults, on: :create

  monetize :amount_cents, with_model_currency: :currency, allow_nil: true, numericality: {greater_than_or_equal_to: 10}

  jsonb_accessor :metadata,
    fee_percent: :float,
    client_pays_fees: [:boolean, default: false]

  pg_search_scope :pg_search,
    against: %i[name],
    associated_against: {
      client: %i[name],
      client_users: %i[name email],
      freelancer: %i[name email],
    }

  class << self
    memoize def for_select
      subclasses.map do |c|
        OpenStruct.new(c::FOR_SELECT.merge(value: c.to_s))
      end
    end

    memoize def short_type
      to_s.underscore.delete_suffix("_project")
    end

    memoize def short_types
      subclasses.map(&:short_type)
    end
  end

  # Create scopes like Project.milestone & type check methods like milestone?
  # while avoiding load-order issues
  SUBCLASS_FILES = "app/models/*_project.rb".freeze
  Dir[SUBCLASS_FILES].each do |file|
    type = File.basename(file, ".*")
    class_name = type.camelize
    type.delete_suffix!("_project")
    scope type, -> { where(type: class_name) }

    define_method "#{type}?" do
      self.class.name == class_name
    end
  end

  memoize def short_type
    self.class.short_type
  end

  memoize def display_type
    short_type.humanize
  end

  def for_subject
    "a project".freeze
  end

  def to_s
    name
  end

private

  def set_defaults
    self.fee_percent ||= freelancer.fee_percent || LIFEWORK_FEE
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end
end
