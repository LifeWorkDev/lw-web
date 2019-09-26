const { environment } = require('@rails/webpacker')
const erb = require('./loaders/erb')

environment.loaders.prepend('erb', erb)
environment.loaders.append('bootstrap-native', {
  test: /bootstrap\.native/,
  use: {
    loader: 'bootstrap.native-loader',
    options: {
      only: ['collapse'],
    },
  },
})
module.exports = environment
