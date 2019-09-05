module ApplicationHelper
  def user_clients_select_options(user)
    user.clients.uniq.map { |client| [client.display_name, client.id] }
  end
end
