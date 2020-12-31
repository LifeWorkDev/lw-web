DoubleEntry.configure do |config|
  config.json_metadata = true

  config.define_accounts do |acct|
    def class_scope(class_name)
      lambda do |record|
        raise "not a #{class_name}" unless record.class.name == class_name

        record.id
      end
    end

    acct.define identifier: :fees
    ACCOUNT_FEES ||= DoubleEntry.account :fees

    acct.define identifier: :stripe_fees, positive_only: true
    ACCOUNT_STRIPE_FEES ||= DoubleEntry.account :stripe_fees

    org_scope = class_scope("Org")
    acct.define identifier: :cash, scope_identifier: org_scope

    user_scope = class_scope("User")
    acct.define identifier: :receivable, scope_identifier: user_scope
    acct.define identifier: :disbursement, scope_identifier: user_scope
  end

  config.define_transfers do |tx|
    tx.define code: :disbursement, from: :receivable, to: :disbursement
    tx.define code: :disbursement_refund, from: :disbursement, to: :cash
    tx.define code: :disbursement_reversal, from: :disbursement, to: :receivable
    tx.define code: :payment, from: :cash, to: :receivable
    tx.define code: :platform, from: :receivable, to: :fees
    tx.define code: :platform_refund, from: :fees, to: :cash
    tx.define code: :platform_reversal, from: :fees, to: :receivable
    tx.define code: :processing, from: :receivable, to: :fees
    tx.define code: :processing_refund, from: :fees, to: :cash
    tx.define code: :processing_reversal, from: :fees, to: :receivable
    tx.define code: :refund, from: :receivable, to: :cash
    tx.define code: :stripe_processing, from: :fees, to: :stripe_fees
    # TODO: Get these monthly around the 2nd @ 9am pacific
    # Stripe::BalanceTransaction.list({type: :stripe_fee}) using created filters for time range
    # https://stripe.com/docs/api/balance_transactions/list
    tx.define code: :stripe_connect_active_accounts, from: :fees, to: :stripe_fees
    tx.define code: :stripe_connect_payouts, from: :fees, to: :stripe_fees
    tx.define code: :stripe_connect_volume, from: :fees, to: :stripe_fees
  end
end
