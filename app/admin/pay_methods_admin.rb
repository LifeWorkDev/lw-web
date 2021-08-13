Trestle.resource(:pay_methods) do
  table do
    column :display_type, header: :Type
    column :name
    column :issuer
    column :kind
    column :last_4, sort: false
    column :expires, sort: false
    column :created_at
  end

  # Customize the form fields shown on the new/edit views.
  #
  form do |record|
    tab :pay_method do
      auto_field :org
      auto_field :display_type, label: :Type
      auto_field :name
      auto_field :issuer
      auto_field :kind
      auto_field :last_4
      auto_field :expires
      number_field :fee_percent, min: 0, max: 1, step: :any
      auto_field :created_at
      auto_field :updated_at
    end

    tab :payments, badge: record.payments.size do
      table PaymentsAdmin.table, collection: record.payments.order(:id)
    end
  end
end
