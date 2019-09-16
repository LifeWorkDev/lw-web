class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
  belongs_to :commenter, class_name: 'User'
  belongs_to :read_by, class_name: 'User', optional: true

  validates :comment, presence: true

  def formatted_created_at
    I18n.l(created_at, format: :date_time)
  end

  def formatted_read_at
    read_at && I18n.l(read_at, format: :date_time)
  end
end
