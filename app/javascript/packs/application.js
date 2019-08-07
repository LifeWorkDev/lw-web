// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

// require("@rails/activestorage").start()
// require("channels")

import 'application/application.scss'

import 'controllers'
require('@rails/ujs').start()
require('turbolinks').start()

// https://github.com/turbolinks/turbolinks/issues/430#issuecomment-444767978
document.addEventListener('turbolinks:request-start', event =>
  event.data.xhr.setRequestHeader(
    'X-Turbolinks-Nonce',
    document.querySelector('meta[name=csp-nonce]').content,
  ),
)

require.context('../images', true)
