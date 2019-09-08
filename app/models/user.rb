class User < ApplicationRecord
  include Status
  include Users::Roles

  belongs_to :org, optional: true
  has_many :projects, dependent: :destroy
  has_many :clients, -> { distinct }, through: :projects
  has_many :org_projects, through: :org, source: :projects

  devise :database_authenticatable, :lockable,
         :invitable, :registerable, :recoverable,
         :rememberable, :trackable, :validatable

  jsonb_accessor :metadata,
                 work_category: [:string, array: true, default: []],
                 work_type: :string

private

  def after_confirmation
    user.activate! unless user.active?
  end
end
