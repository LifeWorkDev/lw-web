Trestle.resource(:comments) do
  menu do
    item :comments, icon: 'fa fa-comments', priority: 4
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

  collection { Comment.order(id: :asc) }

  table do
    column :id, sort: { default: true, default_order: :asc }
    column :commenter, sort: :commenter_id
    column :commentable, header: 'Commented on', sort: :commentable_id
    column :comment, sort: false
    column :created_at, align: :center
    column :updated_at, align: :center
  end

  # Customize the form fields shown on the new/edit views.
  #
  form do |comment|
    collection_select_with_link :commenter_id, User.all, :id, :name
    auto_field 'Commented on', comment.commentable
    text_area :comment
    auto_field :created_at
    auto_field :updated_at
    auto_field :read_by
    auto_field :read_at
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
