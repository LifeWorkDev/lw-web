process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const merge = require('webpack-merge');
const environment = require('./environment');

environment.loaders.append('eslint', {
  enforce: 'pre',
  test: /\.jsx?$/,
  exclude: /node_modules/,
  loader: 'eslint-loader',
  options: {
    emitWarning: true,
    fix: true
  }
});

module.exports = merge(environment.toWebpackConfig(), {
  devServer: {
    noInfo: true
  },
  devtool: 'inline-cheap-module-source-map',
  node: {
    fs: 'empty'
  }
});
