process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const merge = require('webpack-merge')
const environment = require('./environment')

// Get the object hash for our single eslintrc to use as a cache identifier
const objectHash = require('object-hash')
const eslintCacheIdentifier = objectHash(require('../../.eslintrc.js'))
environment.loaders.append('eslint', {
  enforce: 'pre',
  loader: 'eslint-loader',
  options: {
    cache: true,
    cacheIdentifer: eslintCacheIdentifier,
    emitWarning: true,
    fix: true,
  },
  test: /\.jsx?$/,
})

const StylelintPlugin = require('stylelint-webpack-plugin')
environment.plugins.append(
  'stylelint',
  new StylelintPlugin({
    context: 'app/javascript',
    fix: true,
  }),
)

module.exports = merge(environment.toWebpackConfig(), {
  devServer: {
    stats: 'minimal',
  },
  devtool: 'inline-cheap-module-source-map',
  node: {
    fs: 'empty',
  },
})
