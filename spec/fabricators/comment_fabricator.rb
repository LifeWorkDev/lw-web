Fabricator(:comment) do
  commenter(fabricator: :user)
  comment { Faker::Company.bs }

  after_build do |comment|
    comment.commentable ||= Fabricate.build(:milestone)
  end
end

Fabricator(:read_comment, from: :comment) do
  read_at { Faker::Time.between(from: 10.days.ago, to: 30.days.from_now) }
  read_by(fabricator: :user)
end
