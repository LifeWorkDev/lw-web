class Project < ApplicationRecord
  has_logidze
  include Projects::Status
  include STIPreload
  extend FriendlyId
  friendly_id :name, use: :scoped, scope: :user_id

  belongs_to :client, class_name: 'Org', foreign_key: :org_id, inverse_of: :projects
  belongs_to :freelancer, class_name: 'User', foreign_key: :user_id, inverse_of: :projects

  monetize :amount_cents, with_model_currency: :currency, allow_nil: true, numericality: { greater_than_or_equal_to: 0 }

  class << self
    delegate :fa_url, :mdi_url, to: 'ApplicationController.helpers', private: true

    memoize def for_select
      subclasses.map do |c|
        OpenStruct.new(c::FOR_SELECT.merge(value: c.to_s))
      end
    end
  end

  # Create scopes like Project.milestone & type check methods like milestone?
  # while avoiding load-order issues
  SUBCLASS_FILES = 'app/models/*_project.rb'.freeze
  Dir[SUBCLASS_FILES].each do |file|
    type = File.basename(file, '.*')
    class_name = type.camelize
    type.delete_suffix!('_project')
    scope type, -> { where(type: class_name) }

    define_method "#{type}?" do
      self.class.name == class_name
    end
  end

  def amount_with_fee
    amount * (1 + LIFEWORK_FEE)
  end

  memoize def short_type
    self.class.to_s.underscore.delete_suffix('_project')
  end

  memoize def display_type
    short_type.humanize
  end

  def to_s
    name
  end

private

  def should_generate_new_friendly_id?
    name_changed? || super
  end
end
