class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
  belongs_to :commenter, class_name: 'User'
  belongs_to :read_by, class_name: 'User', optional: true

  validates :comment, presence: true
end
