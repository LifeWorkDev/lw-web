process.env.NODE_ENV = process.env.NODE_ENV || 'production'

const environment = require('./environment')
environment.config.optimization.minimizer.find(
  m => m.constructor.name === 'TerserPlugin',
).options.terserOptions.compress.drop_console = true

module.exports = environment.toWebpackConfig()
