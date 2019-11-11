environment ENV.fetch('RAILS_ENV') { 'development' }
port        ENV.fetch('PORT') { 3000 }
workers 1

if Rails.env.development?
  # Allow puma to be restarted by `rails restart` command.
  plugin :tmp_restart

  after_worker_boot do
    title = 'LifeWork server started'
    defined?(TerminalNotifier) && TerminalNotifier::Guard.success('', title: title)
    defined?(Libnotify) && Libnotify.show(summary: title)
    # Trick Webpack into reloading browser
    `touch app/javascript/packs/application.js.erb`
  end
else
  preload_app!

  before_fork do
    @que_pid ||= spawn('bin/que')
  end
end
