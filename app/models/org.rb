class Org < ApplicationRecord
  has_logidze
  include Status
  include WorkCategoryToIntercomTags
  extend FriendlyId
  friendly_id :display_name

  has_many :pay_methods, dependent: :destroy
  has_many :bank_accounts, dependent: :destroy, class_name: 'PayMethods::BankAccount'
  has_many :cards, dependent: :destroy, class_name: 'PayMethods::Card'
  has_many :projects, dependent: :destroy, inverse_of: :client
  accepts_nested_attributes_for :projects
  has_many :users, dependent: :nullify
  accepts_nested_attributes_for :users

  jsonb_accessor :metadata,
                 work_category: [:string, array: true, default: []],
                 work_frequency: :string

  WORK_FREQUENCY = ['Regularly', 'Sometimes', 'Rarely', 'Just this once'].freeze

  def display_name
    self[:name].presence || primary_contact&.name
  end

  def primary_contact
    users.first
  end

  def primary_pay_method
    pay_methods.last
  end

  memoize def stripe_obj
    Stripe::Customer.retrieve(stripe_id)
  end

  def to_s
    display_name
  end

private

  memoize def intercom_metadata
    { companies: [{ company_id: id }] }
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end
end
