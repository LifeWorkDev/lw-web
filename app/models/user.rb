class User < ApplicationRecord
  devise :confirmable, :database_authenticatable, :lockable,
         :invitable, :registerable, :recoverable, :rememberable,
         :timeoutable, :trackable, :validatable
end
