require 'rails_helper'

RSpec.describe CommentRepliesMailbox, type: :mailbox do
  let(:user) { Fabricate(:freelancer) }
  let(:milestone) { Fabricate(:milestone) }

  context 'with known user, known milestone' do
    subject(:inbound_email) do
      receive_inbound_email_from_mail(
        from: milestone.project.freelancer.email,
        to: "comments-#{milestone.id}@#{REPLIES_HOST}",
        subject: 'Sample Subject',
        body: "I'm a sample body",
      )
    end

    it do
      expect { inbound_email }.to change { milestone.comments.count }.by(1)
    end
  end

  context 'with known user but not known to milestone, known milestone' do
    subject(:inbound_email) do
      receive_inbound_email_from_mail(
        from: user.email,
        to: "comments-#{milestone.id}@#{REPLIES_HOST}",
        subject: 'Sample Subject',
        body: "I'm a sample body",
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
        subject: 'Sample Subject',
        body: "I'm a sample body",
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
        subject: 'Sample Subject',
        body: "I'm a sample body",
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
        subject: 'Sample Subject',
        body: "I'm a sample body",
      )
    end

    it do
      expect { inbound_email }.not_to change { Comment.count }
    end
  end
end
