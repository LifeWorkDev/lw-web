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
    scope.new(attrs)
  end

  collection { Project.order(id: :asc) }

  table do
    column :id, sort: { default: true, default_order: :asc }
    column :name
    column :status, sort: :status, align: :center do |project|
      status_tag(project.status.humanize, project.status_class)
    end
    column :type
    column :freelancer, sort: :user_id
    column :client, sort: :org_id
    column :amount, align: :right, sort: :amount_cents do |obj|
      obj.amount&.format
    end
    column :created_at, align: :center
    column :updated_at, align: :center
  end

  # Customize the form fields shown on the new/edit views.
  #
  form do |project|
    tab :project do
      text_field :name
      auto_field :slug
      collection_select_with_link :org_id, Org.all, :id, :name, label: 'Client'
      collection_select_with_link :user_id, User.freelancer, :id, :name, label: 'Freelancer'
      select :status, Project.aasm.states_for_select
      collection_select :type, Project.subclasses, :to_s, :to_s
      number_field :amount, prepend: '$'
      select :currency, Money::Currency.map(&:iso_code)
      number_field :fee_percent, min: 0, max: 1, step: 0.01
      date_field :start_date, required: true if project.retainer?
      auto_field :created_at
      auto_field :updated_at
    end

    if project.milestone?
      tab :milestones, badge: project.milestones.size do
        table MilestonesAdmin.table, collection: project.milestones
        concat admin_link_to('New Milestone', admin: :milestones, action: :new, params: { project_id: project.id }, class: 'btn btn-success mt-3')
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
  #   params.require(:project).permit(:name, ...)
  # end
end
