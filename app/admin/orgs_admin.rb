Trestle.resource(:orgs) do
  menu do
    item :orgs, icon: 'fa fa-building', priority: 1
  end

  # Customize the table columns shown on the index view.

  table do
    column :id
    column :display_name
    column :status, sort: :status, align: :center do |org|
      status_tag(org.status, { 'pending' => :warning, 'active' => :success, 'disabled' => :danger }[org.status] || :default)
    end
    column :primary_contact
    column :created_at
    actions
  end

  # Customize the form fields shown on the new/edit views.

  form do |org|
    tab :org do
      text_field :name
      static_field :slug, org.slug
      select :status, Org.aasm.states.map(&:name)
      select :work_category, []
      text_area :work_frequency
    end

    tab :users, badge: org.users.size do
      table UsersAdmin.table, collection: org.users
      concat admin_link_to('New User', admin: :users, action: :new, params: { org_id: org.id }, class: 'btn btn-success')
    end

    tab :projects, badge: org.projects.size do
      table ProjectsAdmin.table, collection: org.projects
      concat admin_link_to('New Project', admin: :projects, action: :new, params: { org_id: org.id }, class: 'btn btn-success')
    end

    tab :pay_methods, badge: org.pay_methods.size do
      table org.pay_methods, sortable: true do
        column :display_type, header: :Type
        column :name
        column :issuer
        column :kind
        column :last_4, sort: false
        column :expires, sort: false
        column :created_at
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
