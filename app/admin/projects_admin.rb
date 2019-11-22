Trestle.resource(:projects) do
  menu do
    item :projects, icon: 'fa fa-briefcase', priority: 2
  end

  build_instance do |attrs, params|
    scope = if params[:org_id]
              Org.find(params[:org_id]).projects
            elsif params[:user_id]
              User.find(params[:user_id]).projects
            else
              Project
            end
    scope.new(attrs.merge(type: MilestoneProject))
  end

  # Customize the table columns shown on the index view.
  #
  table do
    column :id
    column :name
    column :status, sort: :status, align: :center do |project|
      status_tag(project.status, { 'pending' => :warning, 'active' => :success, 'disabled' => :danger }[project.status] || :default)
    end
    column :type
    column :freelancer
    column :client
    column :created_at
    actions
  end

  # Customize the form fields shown on the new/edit views.
  #
  form do |project|
    tab :project do
      text_field :name
      auto_field :slug
      collection_select_with_link :org_id, Org.all, :id, :name, label: 'Client'
      collection_select_with_link :user_id, User.all, :id, :name, label: 'Freelancer'
      select :status, Project.aasm.states.map(&:name)
      number_field :amount, prepend: '$'
      select :currency, Money::Currency.map(&:iso_code)
      auto_field :created_at
      auto_field :updated_at
    end

    tab :milestones, badge: project.milestones.size do
      table MilestonesAdmin.table, collection: project.milestones
      concat admin_link_to('New Milestone', admin: :milestones, action: :new, params: { project_id: project.id }, class: 'btn btn-success')
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
  #   params.require(:project).permit(:name, ...)
  # end
end
