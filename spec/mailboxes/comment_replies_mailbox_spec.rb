require "rails_helper"

RSpec.describe CommentRepliesMailbox, type: :mailbox do
  let(:user) { Fabricate(:user) }
  let(:milestone) { Fabricate(:milestone) }
  let(:project) { Fabricate(:retainer_project) }
  let(:subject_line) { Faker::Lorem.sentence }
  let(:body) { Faker::Lorem.paragraphs(number: rand(2..5)).join("\n") }

  context "with known user, known milestone" do
    subject(:inbound_email) do
      receive_inbound_email_from_mail(
        from: milestone.freelancer.email,
        to: milestone.comment_reply_address,
        subject: subject_line,
        body: body,
      )
    end

    it do
      expect { inbound_email }.to change { milestone.comments.count }.by(1)
      expect(milestone.comments.last.comment).to eq body
    end
  end

  context "with known user not associated with known milestone" do
    subject(:inbound_email) do
      receive_inbound_email_from_mail(
        from: user.email,
        to: milestone.comment_reply_address,
        subject: subject_line,
        body: body,
      )
    end

    it do
      expect { inbound_email }.to not_change { Comment.count }
    end
  end

  context "with unknown user, known milestone" do
    subject(:inbound_email) do
      receive_inbound_email_from_mail(
        from: "testing@mailinator",
        to: milestone.comment_reply_address,
        subject: subject_line,
        body: body,
      )
    end

    it do
      expect { inbound_email }.to not_change { Comment.count } &
        raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context "with known user, unknown milestone" do
    subject(:inbound_email) do
      receive_inbound_email_from_mail(
        from: user.email,
        to: "comments-foobar-1@#{REPLIES_HOST}",
        subject: subject_line,
        body: body,
      )
    end

    it do
      expect { inbound_email }.to not_change { Comment.count } &
        raise_error(NameError)
    end
  end

  context "with unknown user, unknown milestone" do
    subject(:inbound_email) do
      receive_inbound_email_from_mail(
        from: "testing@mailinator.com",
        to: "comments-foobar-1@#{REPLIES_HOST}",
        subject: subject_line,
        body: body,
      )
    end

    it do
      expect { inbound_email }.to not_change { Comment.count } &
        raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context "when legacy inbound email" do
    subject(:inbound_email) do
      receive_inbound_email_from_mail(
        from: user.email,
        to: "comments-1@#{REPLIES_HOST}",
        subject: subject_line,
        body: body,
      )
    end

    it do
      expect { inbound_email }.to not_change { Comment.count } &
        raise_error(ActionMailbox::Router::RoutingError)
    end
  end

  context "with retainer project" do
    subject(:inbound_email) do
      receive_inbound_email_from_mail(
        from: project.freelancer.email,
        to: project.comment_reply_address,
        subject: subject_line,
        body: body,
      )
    end

    it do
      expect { inbound_email }.to change { project.comments.count }.by(1)
      comment = project.comments.last
      expect(comment.commenter).to eq project.freelancer
      expect(comment.comment).to eq body
    end
  end
end
