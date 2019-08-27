process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const merge = require('webpack-merge')
const environment = require('./environment')

// Get the object hash for our single eslintrc to use as a cache identifier
const objectHash = require('object-hash')
const eslintCacheIdentifier = objectHash(require('../../.eslintrc.js'));
environment.loaders.append('eslint', {
  enforce: 'pre',
  exclude: /node_modules/,
  loader: 'eslint-loader',
  options: {
    cache: true,
    cacheIdentifer: eslintCacheIdentifier,
    emitWarning: true,
    fix: true,
  },
  test: /\.jsx?$/,
})

module.exports = merge(environment.toWebpackConfig(), {
  devServer: {
    noInfo: true,
  },
  devtool: 'inline-cheap-module-source-map',
  node: {
    fs: 'empty',
  },
})
