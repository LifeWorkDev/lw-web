environment ENV.fetch('RAILS_ENV') { 'development' }
port        ENV.fetch('PORT') { 3000 }
workers 1

preload_app!

if Rails.env.development?
  # Allow puma to be restarted by `rails restart` command.
  plugin :tmp_restart

  after_worker_boot do
    TerminalNotifier::Guard.success('', title: 'Server started')
    # Trick Webpack into reloading browser
    `touch app/javascript/packs/application.js`
  end
end
