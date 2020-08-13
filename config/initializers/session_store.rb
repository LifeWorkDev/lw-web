# Remove when Rails 6.1 released
Rails.application.config.session_store :cookie_store, key: "_life_work_session", same_site: :strict, secure: !Rails.env.test?
