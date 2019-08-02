web: bin/rails server -u puma -p $PORT -e $RAILS_ENV
worker: bin/sidekiq -c ${SIDEKIQ_WORKERS-10}
release: bin/rails db:migrate
