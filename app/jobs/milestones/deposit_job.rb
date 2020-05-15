module Milestones
  class DepositJob < Job
    def perform(milestone)
      super
      milestone.deposit!
    end
  end
end
