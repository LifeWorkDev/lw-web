port ENV.fetch("PORT", 3000)

if Rails.env.development?
  silence_single_worker_warning
  threads 1, 1
  workers 1

  # Allow puma to be restarted by `rails restart` command.
  plugin :tmp_restart

  # Puma::Single.class_eval do
  #   alias :orig_run :run
  #   def run
  #     pp @launcher.events
  #     @launcher.events.on_booted do
  #       title = "Bakesy server started"
  #       defined?(TerminalNotifier) && TerminalNotifier::Guard.success("", title: title)
  #       defined?(Libnotify) && Libnotify.show(summary: title)
  #     end
  #     orig_run
  #   end
  # end

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
