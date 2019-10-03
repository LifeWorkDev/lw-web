require 'rails_helper'

RSpec.describe CommentRepliesMailbox, type: :mailbox do
  let(:user) { Fabricate(:freelancer) }
  let(:milestone) { Fabricate(:milestone) }
  let(:subject_line) { Faker::Lorem.sentence }
  let(:body) { Faker::Lorem.paragraphs(number: rand(2..5)).join("\n") }

  context 'with known user, known milestone' do
    subject(:inbound_email) do
      receive_inbound_email_from_mail(
        from: milestone.project.freelancer.email,
        to: "comments-#{milestone.id}@#{REPLIES_HOST}",
        subject: subject_line,
        body: body,
      )
    end

    it do
      expect { inbound_email }.to change { milestone.comments.count }.by(1)
      expect(milestone.comments.last.comment).to eq body
    end
  end

  context 'with known user but not known to milestone, known milestone' do
    subject(:inbound_email) do
      receive_inbound_email_from_mail(
        from: user.email,
        to: "comments-#{milestone.id}@#{REPLIES_HOST}",
        subject: subject_line,
        body: body,
      )
    end

    it do
      expect { inbound_email }.not_to change { Comment.count }
    end
  end

  context 'with unknown user, known milestone' do
    subject(:inbound_email) do
      receive_inbound_email_from_mail(
        from: 'testing@mailinator',
        to: "comments-#{milestone.id}@#{REPLIES_HOST}",
        subject: subject_line,
        body: body,
      )
    end

    it do
      expect { inbound_email }.not_to change { Comment.count }
    end
  end

  context 'with known user, unknown milestone' do
    subject(:inbound_email) do
      receive_inbound_email_from_mail(
        from: user.email,
        to: "comments-23432424234@#{REPLIES_HOST}",
        subject: subject_line,
        body: body,
      )
    end

    it do
      expect { inbound_email }.not_to change { Comment.count }
    end
  end

  context 'with unknown user, unknown milestone' do
    subject(:inbound_email) do
      receive_inbound_email_from_mail(
        from: 'testing@mailinator.com',
        to: "comments-23432424234@#{REPLIES_HOST}",
        subject: subject_line,
        body: body,
      )
    end

    it do
      expect { inbound_email }.not_to change { Comment.count }
    end
  end
end
