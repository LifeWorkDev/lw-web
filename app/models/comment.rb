class Comment < ApplicationRecord
  has_logidze
  belongs_to :commentable, polymorphic: true
  belongs_to :commenter, class_name: "User"
  belongs_to :read_by, class_name: "User", optional: true

  validates :comment, presence: true

  after_create_commit -> { CommentMailer.with(recipient: recipient, milestone: commentable).notify_new_comment.deliver_later(wait: 5.minutes) if commentable.is_a? Milestone }

  pg_search_scope :pg_search,
                  against: %i[comment],
                  associated_against: {commenter: %i[name]}

  def formatted_created_at
    l(created_at)
  end

  def formatted_read_at
    read_at && l(read_at)
  end

  def recipient
    project = commentable.project
    project.freelancer == commenter ? project.client.primary_contact : project.freelancer
  end
end
