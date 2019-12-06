Trestle.resource(:users) do
  menu do
    item :users, icon: 'fa fa-user', priority: 0
  end

  build_instance do |attrs, params|
    scope = params[:org_id] ? Org.find(params[:org_id]).users : User
    scope.new(attrs)
  end

  collection { User.order(id: :asc) }

  table do
    column :id, sort: { default: true, default_order: :asc }
    column :name
    column :email
    column :status, sort: :status, align: :center do |user|
      status_tag(user.status, { 'pending' => :warning, 'active' => :success, 'disabled' => :danger }[user.status] || :default)
    end
    column :roles, sort: :roles, format: :tags, class: 'hidden-xs', &:roles
    column :org, sort: :org_id
    column :created_at, align: :center
    column :current_sign_in_at, align: :center, header: 'Signed in at'
    actions do |toolbar, instance, _admin|
      toolbar.link 'Impersonate', main_app.users_impersonate_path(instance), method: :post, style: :secondary, icon: 'fa fa-mask', title: 'Impersonate user' unless instance == current_user
    end
  end

  # Customize the form fields shown on the new/edit views.
  #
  form do |user|
    tab :user do
      text_field :name
      email_field :email
      select :status, User.aasm.states_for_select
      select :roles, User::ROLES, {}, multiple: true
      time_zone_select :time_zone, ActiveSupport::TimeZone.basic_us_zones, include_blank: true
      collection_select_with_link :org_id, Org.all, :id, :name, include_blank: true
      phone_field :phone
      text_field :address
      if user.invited_by_id.present?
        auto_field :invited_by
        auto_field :invitation_accepted_at
      end
      auto_field :current_sign_in_at
      auto_field :created_at
      auto_field :updated_at
      concat link_to '<i class="fa fa-mask"></i> Impersonate'.html_safe, main_app.users_impersonate_path(instance), method: :post, class: 'btn btn-secondary', title: 'Impersonate user' unless instance == current_user
    end

    tab :questionnaire do
      select :work_category, WORK_CATEGORIES, {}, disabled: true, multiple: true
      auto_field :work_type
    end

    tab :projects, badge: user.projects.size do
      table ProjectsAdmin.table, collection: user.projects
      concat admin_link_to('New Project', admin: :projects, action: :new, params: { user_id: user.id }, class: 'btn btn-success')
    end

    tab :comments, badge: user.comments.size do
      table CommentsAdmin.table, collection: user.comments
      concat admin_link_to('New Comment', admin: :comments, action: :new, params: { commenter_id: user.id }, class: 'btn btn-success')
    end
  end

  controller do
    before_action :remove_blank_role_password, only: %i[create update]

    def remove_blank_role_password
      params[:user][:roles].delete('')
      params[:user].delete_if { |key, value| key == 'password' && value.blank? }
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
