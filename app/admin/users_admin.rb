Trestle.resource(:users) do
  menu do
    item :users, icon: 'fa fa-user', priority: 0
  end

  build_instance do |attrs, params|
    scope = params[:org_id] ? Org.find(params[:org_id]).users : User
    scope.new(attrs)
  end

  # Customize the table columns shown on the index view.
  #
  table do
    column :id
    column :name
    column :email
    column :status, sort: :status, align: :center do |user|
      status_tag(user.status, { 'pending' => :warning, 'active' => :success, 'disabled' => :danger }[user.status] || :default)
    end
    column :roles, format: :tags, class: 'hidden-xs', &:roles
    column :org
    column :created_at, align: :center
    actions do |toolbar, instance, _admin|
      toolbar.link 'Sign in as', main_app.users_impersonate_path(id: instance.id)
      toolbar.delete
    end
  end

  # Customize the form fields shown on the new/edit views.
  #
  form do |user|
    tab :user do
      text_field :name
      email_field :email
      select :status, User.aasm.states.map(&:name)
      select :roles, User::ROLES, {}, multiple: true
      phone_field :phone
      text_field :address
      time_zone_select :time_zone, ActiveSupport::TimeZone.basic_us_zones, include_blank: 'Please select'
      collection_select :org_id, Org.all, :id, :name, include_blank: true
    end

    tab :projects, badge: user.projects.size do
      table user.projects, admin: :projects do
        column :id
        column :name
        column :status
        column :type
        column :freelancer
        column :created_at
        actions
      end
      concat admin_link_to('New Project', admin: :projects, action: :new, params: { user_id: user.id }, class: 'btn btn-success')
    end

    tab :comments, badge: user.comments.size do
      table user.comments, admin: :comments do
        column :id
        column :comment
        column :commentable
        column :read_by
        column :formatted_read_at
        column :formatted_created_at
        actions
      end
      concat admin_link_to('New Comment', admin: :comments, action: :new, params: { commenter_id: user.id }, class: 'btn btn-success')
    end
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
