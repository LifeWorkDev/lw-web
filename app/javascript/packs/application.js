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
// Support component names relative to this directory:
let componentRequireContext = require.context('components', true)
let ReactRailsUJS = require('react_ujs')
ReactRailsUJS.useContext(componentRequireContext)
