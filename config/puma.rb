environment ENV.fetch("RAILS_ENV") { "development" }
port ENV.fetch("PORT", 3000)
workers Integer(ENV.fetch("WEB_WORKERS", 2))
threads_count = Integer(ENV.fetch("RAILS_MAX_THREADS", 5))
threads threads_count, threads_count

if Rails.env.development?
  # Allow puma to be restarted by `rails restart` command.
  plugin :tmp_restart

  after_worker_boot do
    title = "LifeWork server started"
    defined?(TerminalNotifier) && TerminalNotifier::Guard.success("", title: title)
    defined?(Libnotify) && Libnotify.show(summary: title)
    # Trick Webpack into reloading browser
    `touch config/locales/en.yml`
  end
else
  preload_app!

  before_fork do
    @que_pid ||= spawn("bin/que")
  end

  on_worker_boot do
    ActiveRecord::Base.establish_connection
  end
end
