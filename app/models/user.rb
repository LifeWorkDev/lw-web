class User < ApplicationRecord
  include Status
  include Users::Roles

  belongs_to :org, optional: true
  has_many :projects, dependent: :destroy
  has_many :clients, through: :projects, source: :org

  devise :database_authenticatable, :lockable,
         :invitable, :registerable, :recoverable, :rememberable,
         :timeoutable, :trackable, :validatable

  jsonb_accessor :metadata,
                 work_category: [:string, array: true, default: []],
                 work_type: :string

private

  def after_confirmation
    user.activate! unless user.active?
  end
end
