class Comment < ApplicationRecord
  has_logidze
  belongs_to :commentable, polymorphic: true
  belongs_to :commenter, class_name: 'User'
  belongs_to :read_by, class_name: 'User', optional: true

  validates :comment, presence: true

  def formatted_created_at
    l(created_at)
  end

  def formatted_read_at
    read_at && l(read_at)
  end
end
