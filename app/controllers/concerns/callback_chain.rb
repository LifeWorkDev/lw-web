module CallbackChain
  extend ActiveSupport::Concern

  included do
    def self.callback_chain
      _process_action_callbacks.map(&:raw_filter)
    end
  end
end
