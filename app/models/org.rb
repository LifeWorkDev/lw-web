class Org < ApplicationRecord
  has_logidze
  include Status
  include WorkCategoryToIntercomTags
  extend FriendlyId
  friendly_id :name

  has_many :pay_methods, dependent: :destroy
  has_many :payments, through: :users
  has_many :bank_accounts, dependent: :destroy, class_name: 'PayMethods::BankAccount'
  has_many :cards, dependent: :destroy, class_name: 'PayMethods::Card'
  has_many :projects, dependent: :destroy, inverse_of: :client
  accepts_nested_attributes_for :projects
  has_many :users, dependent: :nullify
  accepts_nested_attributes_for :users

  alias orig_nilify_blanks nilify_blanks

  validates :name, presence: true

  jsonb_accessor :metadata,
                 work_category: [:string, array: true, default: []],
                 work_frequency: :string

  WORK_FREQUENCY = ['Regularly', 'Sometimes', 'Rarely', 'Just this once'].freeze

  memoize def account_cash
    DoubleEntry.account(:cash, scope: self)
  end

  def primary_contact
    users.first
  end

  def primary_pay_method
    pay_methods.last
  end

  memoize def stripe_obj
    get_stripe_obj
  end

  def get_stripe_obj
    Stripe::Customer.retrieve(stripe_id)
  end

  def to_s
    name
  end

private

  memoize def intercom_metadata
    { companies: [{ company_id: id }] }
  end

  def nilify_blanks
    orig_nilify_blanks
    return unless new_record?

    self.name ||= primary_contact&.name
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end
end
