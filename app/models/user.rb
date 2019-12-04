class User < ApplicationRecord
  has_logidze
  include Status
  include Users::Roles
  include WorkCategoryToIntercomTags

  belongs_to :org, optional: true
  has_many :projects, dependent: :destroy
  has_many :clients, -> { distinct }, through: :projects
  has_many :org_projects, through: :org, source: :projects
  has_many :comments, foreign_key: :commenter_id, dependent: :destroy, inverse_of: :commenter

  devise :database_authenticatable, :lockable,
         :invitable, :registerable, :recoverable,
         :rememberable, :trackable, :validatable

  jsonb_accessor :metadata,
                 work_category: [:string, array: true, default: []],
                 work_type: :string

  def after_database_authentication
    activate! unless active?
  end

  def client?
    org_id.present?
  end

  def freelancer?
    !client?
  end

  def active_freelancer?
    freelancer? && projects.not_pending.any?
  end

  def reminder_time(time)
    time.in_time_zone(time_zone || 'Pacific Time (US & Canada)')
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
end
