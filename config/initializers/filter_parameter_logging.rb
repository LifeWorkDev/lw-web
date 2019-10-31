# Configure sensitive parameters which will be filtered from the log file.
params = %i[password]
Rails.application.config.filter_parameters += params
