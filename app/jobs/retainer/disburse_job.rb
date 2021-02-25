module Retainer
  class DisburseJob < Job
    def perform(payment)
      raise "Not a payment" unless payment.is_a? Payment
      retainer_project = payment.pays_for
      super(retainer_project)

      retainer_project.disburse!(payment)
    end
  end
end
