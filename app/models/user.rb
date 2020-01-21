class User < ApplicationRecord
  has_logidze
  include Status
  include Users::Roles
  include WorkCategoryToIntercomTags

  belongs_to :org, optional: true
  has_many :projects, dependent: :destroy, inverse_of: :freelancer
  has_many :clients, -> { distinct }, through: :projects
  has_many :org_projects, through: :org, source: :projects
  has_many :comments, foreign_key: :commenter_id, dependent: :destroy, inverse_of: :commenter

  before_validation :set_defaults, on: :create

  devise :database_authenticatable, :lockable,
         :invitable, :registerable, :recoverable,
         :rememberable, :trackable, :validatable

  jsonb_accessor :metadata,
                 work_category: [:string, array: true, default: []],
                 work_type: :string

  scope :client, -> { where.not(org_id: nil) }
  scope :freelancer, -> { where(org_id: nil) }

  WORK_TYPES = ['Part-Time', 'Full-Time', 'Team Leader'].freeze

  def after_database_authentication
    activate! unless active?
  end

  def finished_onboarding?
    client? ? org.active? : projects.not_pending.any?
  end

  def client?
    org_id.present?
  end

  def freelancer?
    !client?
  end

  def max_pending_project_status
    all_statuses = Project.aasm.states.map { |s| s.name.to_s }
    statuses = projects.pending.pluck(:status)
    max_status = statuses.map { |s| all_statuses.find_index(s) }.max
    max_status && all_statuses[max_status]
  end

  def projects_collection
    client? ? org_projects : projects
  end

  def reminder_time(time)
    time.in_time_zone(time_zone || 'Pacific Time (US & Canada)')
  end

  memoize def stripe_obj
    Stripe::Account.retrieve(stripe_id)
  end

  def stripe_dashboard
    Stripe::Account.create_login_link(stripe_id).url
  end

  def type
    client? ? :client : :freelancer
  end

  def to_s
    name
  end

  memoize def in_north_america?
    ActiveSupport::TimeZone.basic_us_zone_names.include? time_zone
  end

protected

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def skip_invitation
    true # Never send default invitation email when using invite!
  end

private

  memoize def intercom_metadata
    { users: [{ user_id: id }] }
  end

  def set_defaults
    self.password ||= Devise.friendly_token[0, 20]
  end
end
