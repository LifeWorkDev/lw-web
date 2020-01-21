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
      state :disabled

      event :invite_client do
        transitions from: :contract_sent, to: :client_invited

        after do
          user = client.primary_contact
          ClientMailer.with(recipient: user, project: self).invite.deliver_later
        end
      end

      event :activate do
        transitions from: :client_invited, to: :active
      end

      event :disable do
        transitions from: %i[pending active], to: :disabled
      end

      event :enable do
        transitions from: :disabled, to: :active
      end
    end

    STATE_NAMES = aasm.states.map(&:name).freeze
    PENDING_STATES = STATE_NAMES.first(STATE_NAMES.find_index(:client_invited)).freeze

    def pending?
      PENDING_STATES.include? status.to_sym
    end

    memoize def status_class
      if status.to_sym == self.class.aasm.initial_state then :warning
      elsif proposal_sent? then :secondary
      elsif proposal_agreed? then :info
      elsif contract_sent? then :primary
      elsif active? then :success
      else :light
      end
    end
  end
end
