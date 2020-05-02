Trestle.resource(:orgs) do
  menu do
    item :orgs, icon: "fa fa-building", priority: 1
  end

  collection { Org.order(id: :asc) }

  table do
    column :id, sort: { default: true, default_order: :asc }
    column :name
    column :status, sort: :status, align: :center do |org|
      status_tag(org.status.humanize, org.status_class)
    end
    column :primary_contact, sort: false
    column :created_at, align: :center
    column :updated_at, align: :center
  end

  # Customize the form fields shown on the new/edit views.

  form do |org|
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

    tab :users, badge: org.users.size do
      table UsersAdmin.table, collection: org.users
      concat admin_link_to("New User", admin: :users, action: :new, params: { org_id: org.id }, class: "btn btn-success mt-3")
    end

    tab :projects, badge: org.projects.size do
      table ProjectsAdmin.table, collection: org.projects
      concat admin_link_to("New Project", admin: :projects, action: :new, params: { org_id: org.id }, class: "btn btn-success mt-3")
    end

    tab :pay_methods, badge: org.pay_methods.size do
      table PayMethodsAdmin.table, collection: org.pay_methods
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
