Trestle.configure do |config|
  # == Customization Options
  #
  # Set the page title shown in the main header within the admin.
  #
  config.site_title = "LifeWork admin"

  # Specify a custom image to be used in place of the site title for mobile and
  # expanded/desktop navigation. These images should be placed within your
  # asset paths, e.g. app/assets/images.
  #
  # config.site_logo = 'lifework-logo.png'

  # Specify a custom image to be used for the collapsed/tablet navigation.
  #
  # config.site_logo_small = "logo-small.png"

  # Speficy a favicon to be used within the admin.
  #
  # config.favicon =

  # Set the text shown in the page footer within the admin.
  # Defaults to 'Powered by Trestle'.
  #
  # config.footer = "Powered by Trestle"

  # Sets the default precision for timestamps (either :minutes or :seconds).
  # Defaults to :minutes.
  #
  # config.timestamp_precision = :minutes

  # == Mounting Options
  #
  # Set the path at which to mount the Trestle admin. Defaults to /admin.
  #
  # config.path = "/admin"

  # Toggle whether Trestle should automatically mount the admin within your
  # Rails application's routes. Defaults to true.
  #
  # config.automount = false

  # == Navigation Options
  #
  # Set the path to consider the application root (for title links and breadcrumbs).
  # Defaults to the same value as `config.path`.
  #
  # config.root = "/"

  # Set the initial breadcrumbs to display in the breadcrumb trail.
  # Defaults to a breadcrumb labeled 'Home' linking to to the application root.
  #
  # config.root_breadcrumbs = -> { [Trestle::Breadcrumb.new("Home", Trestle.config.root)] }

  # Set the default icon class to use when it is not explicitly provided.
  # Defaults to "fa fa-arrow-circle-o-right".
  #
  # config.default_navigation_icon = "fa fa-arrow-circle-o-right"

  # Add an explicit menu block to be added to the admin navigation.
  #
  config.menu do
    item "Background Jobs", "/admin/que", data: {turbolinks: false}, icon: "fa fa-cogs", priority: :last
    mailers_path = Rails.env.development? ? "/rails/mailers" : "/admin/mailers"
    item "Email Templates", mailers_path, icon: "fa fa-envelope-open-text", priority: :last
  end

  # == Extension Options
  #
  # Specify helper modules to expose to the admin.
  #
  config.helper [Helpers::TrestleHelper]

  # Register callbacks to run before, after or around all Trestle actions.
  #
  # config.before_action do |controller|
  #   Rails.logger.debug("Before action")
  # end
  #
  # config.after_action do |controller|
  #   Rails.logger.debug("After action")
  # end
  #
  # config.around_action do |controller, block|
  #   Rails.logger.debug("Around action (before)")
  #   block.call
  #   Rails.logger.debug("Around action (after)")
  # end

  # Specify a custom hook to be injected into the admin.
  #
  if defined?(WEBPACK_SCRIPT_TAG)
    config.hook(:javascripts) do
      WEBPACK_SCRIPT_TAG.html_safe # rubocop:disable Rails/OutputSafety
    end
  end

  # Toggle whether Turbolinks is enabled within the admin.
  # Defaults to true if Turbolinks is available.
  #
  # config.turbolinks = false

  # Specify the parameters that should persist across requests when
  # paginating or reordering. Defaults to [:sort, :order, :scope].
  #
  # config.persistent_params << :query

  # Customize the default adapter class used by all admin resources.
  # See the documentation on Trestle::Adapters::Adapter for details on
  # the adapter methods that can be customized.
  #
  # config.default_adapter = Trestle::Adapters.compose(Trestle::Adapters::SequelAdapter)
  # config.default_adapter.include MyAdapterExtensions

  # Register a form field type to be made available to the Trestle form builder.
  # Field types should conform to the following method definition:
  #
  config.form_field :auto_field, Fields::AutoField
  config.form_field :collection_select_with_link, Fields::CollectionSelectWithLink

  # == Debugging Options
  #
  # Enable debugging of form errors. Defaults to true in development mode.
  #
  # config.debug_form_errors = true
  # Optional, but it is always nice to give folks the option of
  # logging out:
  config.hook "view.header" do
    render "admin/header"
  end

  config.hook :head do
    favicon_pack_tag "favicon.ico", rel: "shortcut icon"
  end
end

require "trestle/application_controller"
require "trestle-devise/controller_methods"
Trestle::ApplicationController.include Trestle::Auth::ControllerMethods
Trestle::ApplicationController.include SetLogidzeResponsible
Trestle::ApplicationController.skip_after_action :intercom_rails_auto_include
