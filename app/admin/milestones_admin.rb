Trestle.resource(:milestones) do
  menu do
    item :milestones, icon: 'fa fa-star'
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
    column :amount_cents
    column :project
    column :formatted_date
    column :created_at
    actions
  end

  # Customize the form fields shown on the new/edit views.
  form do |milestone|
    tab :milestone do
      collection_select :project_id, Project.all, :id, :name
      text_field :description
      number_field :amount_cents
      select :status, Milestone.aasm.states.map(&:name)
      date_field :date
    end

    tab :comments, badge: milestone.comments.size do
      table milestone.comments, admin: :comments do
        column :id
        column :comment
        column :commenter
        column :read_by
        column :formatted_read_at
        column :formatted_created_at
        actions
      end
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
