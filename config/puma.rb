port ENV.fetch("PORT", 3000)

if Rails.env.development?
  threads 1, 1
  workers 1

  # Allow puma to be restarted by `rails restart` command.
  plugin :tmp_restart

  after_worker_boot do
    title = "LifeWork server started"
    defined?(TerminalNotifier) && TerminalNotifier::Guard.success("", title: title)
    defined?(Libnotify) && Libnotify.show(summary: title)
    # Trick Webpack into reloading browser
    `touch config/locales/en.yml`
  end
elsif !Rails.env.test?
  fork_worker
  nakayoshi_fork
  workers Integer(ENV["WEB_CONCURRENCY"] || 1)

  before_fork do
    @que_pid ||= spawn("bin/que")
  end
end
