const { webpackConfig, merge, env } = require('shakapacker')
const customConfig = {
  resolve: {
    extensions: ['.css'],
  },
}

if (env.isDevelopment) {
  const chokidar = require('chokidar')
  customConfig.devServer = {
    onBeforeSetupMiddleware: (devServer) => {
      chokidar
        .watch([
          'config/locales/*.yml',
          'app/helpers/**/*',
          'app/views/**/*.slim',
        ])
        .on('change', () =>
          devServer.sendMessage(
            devServer.webSocketServer.clients,
            'content-changed',
          ),
        )
    },
  }

  const EslintPlugin = require('eslint-webpack-plugin')
  const StylelintPlugin = require('stylelint-webpack-plugin')
  customConfig.plugins = [
    new EslintPlugin({
      context: 'app/javascript',
      extensions: ['.js', '.jsx'],
      fix: true,
      lintDirtyModulesOnly: true,
    }),
    new StylelintPlugin({
      context: 'app/javascript',
      fix: true,
      lintDirtyModulesOnly: true,
    }),
  ]
}

module.exports = merge(webpackConfig, customConfig)
