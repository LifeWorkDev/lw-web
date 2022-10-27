Trestle.resource(:orgs) do
  menu do
    item :orgs, icon: "fa fa-building", priority: 1
  end

  collection { Org.order(id: :desc) }

  search do |query|
    query ? collection.pg_search(query) : collection
  end

  table do
    column :id, sort: {default: true, default_order: :desc}
    column :name
    column :status, sort: :status, align: :center do |org|
      status_tag(org.status.humanize, org.status_class)
    end
    column :primary_contact, sort: false
    column :created_at, align: :center
    column :updated_at, align: :center
  end

  # Customize the form fields shown on the new/edit views.

  form do |record|
    tab :org do
      text_field :name
      auto_field :slug
      select :status, Org.aasm.states_for_select
      auto_field :created_at
      auto_field :updated_at
    end

    tab :questionnaire do
      select :work_category, WORK_CATEGORIES, {}, disabled: true, multiple: true
      auto_field :work_frequency
    end

    tab :users, badge: record.users.size do
      table UsersAdmin.table, collection: record.users.order(id: :desc)
      concat admin_link_to("New User", admin: :users, action: :new, params: {org_id: record.id}, class: "btn btn-success mt-3")
    end

    tab :projects, badge: record.projects.size do
      table ProjectsAdmin.table, collection: record.projects.order(id: :desc)
      concat admin_link_to("New Project", admin: :projects, action: :new, params: {org_id: record.id}, class: "btn btn-success mt-3")
    end

    tab :pay_methods, badge: record.pay_methods.size do
      table PayMethodsAdmin.table, collection: record.pay_methods.order(id: :desc)
    end

    tab :payments, badge: record.payments.size do
      table PaymentsAdmin.table, collection: record.payments.order(id: :desc)
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
