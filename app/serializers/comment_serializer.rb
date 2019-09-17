class CommentSerializer < ActiveModel::Serializer
  attributes :id, :comment, :formatted_created_at, :formatted_read_at
  belongs_to :commenter
  belongs_to :read_by
end
