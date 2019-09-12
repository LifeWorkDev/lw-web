module.exports = {
  enforce: 'pre',
  exclude: /node_modules/,
  test: /\.erb$/,
  use: [
    {
      loader: 'rails-erb-loader',
      options: {
        runner:
          (/^win/.test(process.platform) ? 'ruby ' : '') + 'bin/rails runner',
      },
    },
  ],
}
