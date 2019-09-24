Trestle.resource(:orgs) do
  menu do
    item :orgs, icon: 'fa fa-star'
  end

  # Customize the table columns shown on the index view.

  table do
    column :id
    column :display_name
    column :status
    column :primary_contact
    column :created_at
    actions
  end

  # Customize the form fields shown on the new/edit views.

  form do |org|
    tab :org do
      text_field :name
      text_field :slug
      select :status, Org.aasm.states.map(&:name)
      select :work_category, []
      text_area :work_frequency
    end

    tab :users, badge: org.users.size do
      table org.users, admin: :users do
        column :id
        column :name
        column :email
        column :status
        column :created_at
        actions
      end
      concat admin_link_to('New User', admin: :users, action: :new, params: { org_id: org.id }, class: 'btn btn-success')
    end

    tab :projects, badge: org.projects.size do
      table org.projects, admin: :projects do
        column :id
        column :name
        column :status
        column :type
        column :freelancer
        column :created_at
        actions
      end
      concat admin_link_to('New Project', admin: :projects, action: :new, params: { org_id: org.id }, class: 'btn btn-success')
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
