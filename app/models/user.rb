class User < ApplicationRecord
  has_logidze
  include Status
  include Users::Roles
  include WorkCategoryToIntercomTags

  belongs_to :org, optional: true
  has_many :payments, dependent: :destroy
  has_many :projects, dependent: :destroy, inverse_of: :freelancer
  has_many :clients, -> { distinct }, through: :projects
  has_many :org_projects, through: :org, source: :projects
  has_many :comments, foreign_key: :commenter_id, dependent: :destroy, inverse_of: :commenter

  before_validation :set_defaults, on: :create

  devise :database_authenticatable, :lockable,
         :invitable, :registerable, :recoverable,
         :rememberable, :trackable, :validatable

  jsonb_accessor :metadata,
                 fee_percent: :float,
                 how_did_you_hear_about_us: :string,
                 work_category: [:string, array: true, default: []],
                 work_type: :string

  scope :client, -> { where.not(org_id: nil) }
  scope :freelancer, -> { where(org_id: nil) }

  pg_search_scope :pg_search,
                  against: %i[name email],
                  associated_against: {org: %i[name]}

  WORK_TYPES = ["Part-Time", "Full-Time", "Team Leader"].freeze

  def after_database_authentication
    activate! if may_activate?
  end

  memoize def account_disbursement
    DoubleEntry.account(:disbursement, scope: self)
  end

  memoize def account_receivable
    DoubleEntry.account(:receivable, scope: self)
  end

  memoize def client?
    org_id.present?
  end

  def finished_onboarding?
    client? ? org.active? : projects.not_pending.any?
  end

  memoize def freelancer?
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

  def reconcilation_report
    Stripe::Payout.list({limit: 100}, stripe_account: stripe_id).each do |payout|
      puts "#{Money.new(payout.amount).format} on #{Time.at(payout.arrival_date).to_date}" # rubocop:disable Rails/Output
      Stripe::BalanceTransaction.list(
        {
          payout: payout.id,
          type: "payment",
          expand: ["data.source.source_transfer"],
        },
        stripe_account: stripe_id,
      ).each do |baltxn|
        transfer = baltxn.source.source_transfer
        puts "  #{Money.new(transfer.amount).format} for #{transfer.description}" # rubocop:disable Rails/Output
      end
    end
    nil
  end

  def received_payments
    Payment.where(id: DoubleEntry::Line.credits.where(code: :disbursement).jsonb_where(:metadata, destination_account_id: stripe_id).pluck(:detail_id))
  end

  def time_zone_with_fallback
    time_zone || "Pacific Time (US & Canada)"
  end

  def local_time(time)
    time.in_time_zone(time_zone_with_fallback)
  end

  def use_zone
    Time.use_zone(time_zone_with_fallback) { yield }
  end

  memoize def stripe_obj
    get_stripe_obj
  end

  def get_stripe_obj
    Stripe::Account.retrieve(stripe_id)
  end

  def stripe_dashboard
    Stripe::Account.create_login_link(stripe_id).url
  end

  memoize def type
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
    {users: [{user_id: id}]}
  end

  def set_defaults
    password.blank? && self.password = Devise.friendly_token[0, 20]
  end
end
