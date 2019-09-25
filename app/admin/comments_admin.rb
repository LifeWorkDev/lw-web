Trestle.resource(:comments) do
  menu do
    item :comments, icon: 'fa fa-star'
  end

  build_instance do |attrs, params|
    scope = if params[:milestone_id]
              Milestone.find(params[:milestone_id]).comments
            elsif params[:commenter_id]
              User.find(params[:commenter_id]).comments
            else
              Comment
            end
    scope.new(attrs)
  end

  # Customize the table columns shown on the index view.
  #
  table do
    column :id
    column :comment
    column :commentable
    column :commenter
    column :read_by
    column :formatted_read_at
    column :formatted_created_at
    actions
  end

  # Customize the form fields shown on the new/edit views.
  #
  form do |_comment|
    collection_select :commenter_id, User.all, :id, :name
    text_field :comment
    hidden_field :commentable_type, value: 'Milestone'
    collection_select :commentable_id, Milestone.all, :id, :description
    collection_select :read_by_id, User.all, :id, :name, include_blank: true
    datetime_field :read_at
  end

  # By default, all parameters passed to the update and create actions will be
  # permitted. If you do not have full trust in your users, you should explicitly
  # define the list of permitted parameters.
  #
  # For further information, see the Rails documentation on Strong Parameters:
  #   http://guides.rubyonrails.org/action_controller_overview.html#strong-parameters
  #
  # params do |params|
  #   params.require(:comment).permit(:name, ...)
  # end
end
