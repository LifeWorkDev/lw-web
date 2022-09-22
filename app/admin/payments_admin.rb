Trestle.resource(:payments) do
  menu do
    item :payments, icon: "fa fa-money-bill-wave", priority: 5
  end

  collection { Payment.order(id: :desc) }

  search do |query|
    query ? collection.pg_search(query) : collection
  end

  table do
    column :id, sort: {default: true, default_order: :desc}
    column :pays_for, sort: false
    column :status, sort: :status, align: :center do |record|
      status_tag(record.status.humanize, record.status_class)
    end
    column :amount, align: :right, sort: :amount_cents do |record|
      record.amount&.format
    end
    column :pay_method, align: :center, header: nil, sort: false do |record|
      icon "fa fa-#{record.pay_method.card? ? :"credit-card" : :university}"
    end
    column :scheduled_for, header: "Scheduled", align: :center
    column :paid_at, header: "Paid", align: :center
  end

  # Customize the form fields shown on the new/edit views.

  form do |record|
    tab :payment do
      static_field :status do
        status_tag(record.status.humanize, record.status_class)
      end
      auto_field :pays_for
      auto_field :amount
      auto_field :processing_fee
      if record.paid? && record.project?
        number_field :amount_before_fees, prepend: "$", min: 0, step: 0.01, help: '<span class="text-danger">Updating the amount of a payment will immediately issue a refund for the difference</span>'.html_safe
      else
        auto_field :amount_before_fees
      end
      auto_field :platform_fee
      auto_field :freelancer_amount
      auto_field :note
      auto_field :scheduled_for
      auto_field :paid_at
      auto_field :stripe_id
      auto_field :stripe_fee
      auto_field :pay_method
      auto_field :paid_by
      auto_field :recipient
      auto_field :created_at
      auto_field :updated_at
    end

    tab :accounting_records do
      table record.lines.credits do
        column :code
        column :amount do |record|
          record.amount&.format
        end
        column :metadata
        column :created_at
        column :updated_at
      end
    end
  end

  # By default, all parameters passed to the update and create actions will be
  # permitted. If you do not have full trust in your users, you should explicitly
  # define the list of permitted parameters.
  #
  # For further information, see the Rails documentation on Strong Parameters:
  #   http://guides.rubyonrails.org/action_controller_overview.html#strong-parameters
  #
  # params do |params|
  #   params.require(:org).permit(:name, ...)
  # end
end
