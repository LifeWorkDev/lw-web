Trestle.resource(:users) do
  menu do
    item :users, icon: 'fa fa-star'
  end

  # Customize the table columns shown on the index view.
  #
  table do
    column :id
    column :name
    column :email
    column :status
    column :roles
    column :org
    column :created_at, align: :center
    actions do |toolbar, instance, _admin|
      toolbar.link 'Sign in as', main_app.users_impersonate_path(id: instance.id)
      toolbar.delete
    end
  end

  # Customize the form fields shown on the new/edit views.
  #
  form do |_user|
    text_field :name
    email_field :email
    select :status, User.aasm.states.map(&:name)
    select :roles, User::ROLES, {}, multiple: true
    phone_field :phone
    text_field :address
    text_field :time_zone
    select :org_id, [[]] + Org.all.map { |org| [org.name, org.id] }
  end

  controller do
    before_action :remove_blank_role, only: %i[create update]

    def remove_blank_role
      params[:user][:roles].delete('')
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
  #   params.require(:user).permit(:name, ...)
  # end
end
