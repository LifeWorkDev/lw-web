Trestle.resource(:comments) do
  menu do
    item :comments, icon: "fa fa-comments", priority: 4
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

  search do |query|
    query ? collection.pg_search(query) : collection
  end

  table do
    column :id, sort: {default: true, default_order: :asc}
    column :commenter, sort: :commenter_id
    column :commentable, header: "Commented on", sort: :commentable_id
    column :comment, sort: false
    column :created_at, align: :center
    column :updated_at, align: :center
  end

  # Customize the form fields shown on the new/edit views.
  #
  form do |comment|
    if comment.new_record?
      collection_select_with_link :commenter_id, comment.commentable.client.users << comment.commentable.freelancer, :id, :name
    else
      auto_field :commenter
    end
    auto_field :commentable, label: "Commenting on"
    text_area :comment
    if comment.new_record?
      hidden_field :commentable_id
      hidden_field :commentable_type
    else
      auto_field :created_at
      auto_field :updated_at
      auto_field :read_by
      auto_field :read_at
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
  #   params.require(:comment).permit(:name, ...)
  # end
end
