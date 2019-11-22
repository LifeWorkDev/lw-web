Trestle.resource(:milestones) do
  menu do
    item :milestones, icon: 'fa fa-tasks', priority: 3
  end

  build_instance do |attrs, params|
    scope = params[:project_id] ? Project.find(params[:project_id]).milestones : Milestone
    scope.new(attrs)
  end

  # Customize the table columns shown on the index view.
  #
  table do
    column :id
    column :description
    column :status
    column :amount
    column :project
    column :formatted_date
    column :created_at
    actions
  end

  # Customize the form fields shown on the new/edit views.
  form do |milestone|
    tab :milestone do
      collection_select_with_link :project_id, Project.all, :id, :name
      text_field :description
      number_field :amount, prepend: '$'
      select :status, Milestone.aasm.states.map(&:name)
      date_field :date
      auto_field :created_at
      auto_field :updated_at
    end

    tab :comments, badge: milestone.comments.size do
      table CommentsAdmin.table, collection: milestone.comments
      concat admin_link_to('New Comment', admin: :comments, action: :new, params: { milestone_id: milestone.id }, class: 'btn btn-success')
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
  #   params.require(:milestone).permit(:name, ...)
  # end
end
