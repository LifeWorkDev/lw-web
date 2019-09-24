Trestle.resource(:projects) do
  menu do
    item :projects, icon: 'fa fa-star'
  end

  build_instance do |attrs, params|
    scope = params[:org_id] ? Org.find(params[:org_id]).projects : Project
    scope.new(attrs)
  end

  # Customize the table columns shown on the index view.
  #
  table do
    column :id
    column :name
    column :status
    column :type
    column :freelancer
    column :client
    column :created_at
    actions
  end

  # Customize the form fields shown on the new/edit views.
  #
  form do |_project|
    text_field :name
    text_field :slug
    collection_select :org_id, Org.all, :id, :name, label: 'Client'
    collection_select :user_id, User.all, :id, :name, label: 'Freelancer'
    select :status, Project.aasm.states.map(&:name)
    number_field :amount_cents
    text_field :currency
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
