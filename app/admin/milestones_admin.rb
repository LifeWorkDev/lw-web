Trestle.resource(:milestones) do
  menu do
    item :milestones, icon: "fa fa-tasks", priority: 3
  end

  build_instance do |attrs, params|
    scope = params[:project_id] ? Project.find(params[:project_id]).milestones : Milestone
    scope.new(attrs)
  end

  collection { Milestone.order(id: :desc) }

  search do |query|
    query ? collection.pg_search(query) : collection
  end

  table do
    column :id, sort: {default: true, default_order: :desc}
    column :project
    column :date
    column :status, sort: :status, align: :center do |milestone|
      status_tag(milestone.status.humanize, milestone.status_class)
    end
    column :amount, align: :right, sort: :amount_cents do |milestone|
      milestone.amount&.format
    end
    column :description
    column :created_at, align: :center
    column :updated_at, align: :center
  end

  # Customize the form fields shown on the new/edit views.
  form do |record|
    tab :milestone do
      collection_select_with_link :project_id, Project.all, :id, :name
      text_field :description
      if record.pending? || record.deposited? || record.paid?
        help_text = record.pending? ? nil : '<span class="text-danger">Updating the amount of a deposited milestone will immediately issue a refund for the difference</span>'.html_safe
        number_field :amount, prepend: "$", min: 1, step: 0.01, help: help_text
      else
        auto_field :amount
      end
      select :status, Milestone.aasm.states_for_select
      date_field :date
      auto_field :created_at
      auto_field :updated_at
    end

    tab :comments, badge: record.comments.size do
      table CommentsAdmin.table, collection: record.comments.order(:id)
      concat admin_link_to("New Comment", admin: :comments, action: :new, params: {milestone_id: record.id}, class: "btn btn-success mt-3")
    end

    tab :payments, badge: record.payments.size do
      table PaymentsAdmin.table, collection: record.payments.order(:id)
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
