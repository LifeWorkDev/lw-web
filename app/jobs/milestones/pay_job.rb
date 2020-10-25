module Milestones
  class PayJob < Job
    def perform(milestone)
      super
      raise "Can't pay Milestone #{milestone.id} because it's in state #{milestone.status}" unless milestone.may_pay?
      raise "Can't pay Milestone #{milestone.id} before its payment date #{milestone.formatted_date}" unless milestone.payable?

      milestone.pay!
    end
  end
end
