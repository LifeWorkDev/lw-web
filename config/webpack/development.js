process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const merge = require('webpack-merge')
const environment = require('./environment')

const EslintPlugin = require('eslint-webpack-plugin')
environment.plugins.append(
  'eslint',
  new EslintPlugin({
    context: 'app/javascript',
    extensions: ['.js', '.jsx'],
    fix: true,
    lintDirtyModulesOnly: true,
  }),
)

const StylelintPlugin = require('stylelint-webpack-plugin')
environment.plugins.append(
  'stylelint',
  new StylelintPlugin({
    context: 'app/javascript',
    fix: true,
    lintDirtyModulesOnly: true,
  }),
)

const chokidar = require('chokidar')
environment.config.devServer.before = (app, server) => {
  chokidar
    .watch(['config/locales/*.yml', 'app/helpers/**/*', 'app/views/**/*'])
    .on('change', () => setTimeout(() => {
      server.sockWrite(server.sockets, 'content-changed')
    }, 100))
}

module.exports = merge(environment.toWebpackConfig(), {
  devServer: {
    stats: 'minimal',
  },
  devtool: 'inline-cheap-module-source-map',
  node: {
    fs: 'empty',
  },
})
