module Projects::Status
  extend ActiveSupport::Concern

  included do
    include AasmStatus

    aasm do
      state :writing_proposal, initial: true
      state :proposal_sent
      state :proposal_agreed
      state :proposal_rejected
      state :contract_sent
      state :client_invited
      state :active
      state :archived

      event :invite_client do
        transitions from: :contract_sent, to: :client_invited

        after_commit do
          ClientMailer.with(recipient: client.primary_contact, project: self).invite.deliver_later
          Mailers::ClientReminderJob.set(wait: 12.hours).perform_later(self)
        end
      end

      event :activate do
        transitions from: :client_invited, to: :active
      end

      event :archive do
        transitions to: :archived
      end
    end

    STATE_NAMES = aasm.states.map(&:name).freeze
    PENDING_STATES = STATE_NAMES.first(STATE_NAMES.find_index(:client_invited)).freeze # up to, but not including client_invited

    scope :pending, -> { where(status: PENDING_STATES) }
    scope :not_pending, -> { where.not(status: PENDING_STATES) }
    scope :not_archived, -> { where.not(status: :archived) }

    def pending?
      PENDING_STATES.include? status.to_sym
    end

    memoize def status_class
      if status.to_sym == self.class.aasm.initial_state then :warning
      elsif proposal_sent? then :secondary
      elsif proposal_agreed? then :info
      elsif proposal_rejected? then :danger
      elsif contract_sent? then :primary
      elsif active? then :success
      elsif client_invited? then :dark
      else :light
      end
    end
  end
end
