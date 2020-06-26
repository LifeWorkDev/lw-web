Trestle.resource(:payments) do
  menu do
    item :payments, icon: "fa fa-money-bill-wave", priority: 5
  end

  collection { Payment.order(id: :asc) }

  table do
    column :id, sort: {default: true, default_order: :asc}
    column :pays_for, sort: false
    column :status, sort: :status, align: :center do |payment|
      status_tag(payment.status.humanize, payment.status_class)
    end
    column :amount, align: :right, sort: :amount_cents do |obj|
      obj.amount&.format
    end
    column :scheduled_for, align: :center
    column :paid_at, align: :center
  end

  # Customize the form fields shown on the new/edit views.

  form do |payment|
    auto_field :pays_for
    if payment.scheduled?
      number_field :amount, prepend: "$", min: 1, step: 0.01
    else
      auto_field :amount
    end
    static_field :status do
      status_tag(payment.status.humanize, payment.status_class)
    end
    auto_field :scheduled_for
    auto_field :paid_at
    auto_field :stripe_id
    auto_field :stripe_fee
    auto_field :pay_method
    auto_field :user, label: "Initiated by"
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
