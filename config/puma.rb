environment ENV.fetch('RAILS_ENV') { 'development' }
port        ENV.fetch('PORT') { 3000 }
workers 1

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart

preload_app!

after_worker_boot do
  TerminalNotifier::Guard.success('', title: 'Server started')
  # Trick Webpack into reloading browser
  `touch app/javascript/packs/application.js`
end
