import 'application/application.scss'

import 'controllers'
import * as Sentry from '@sentry/browser'
require('@rails/ujs').start()
require('turbolinks').start()

if (process.env.NODE_ENV === 'production') {
  Sentry.init({
    dsn: 'https://5e07926b621741b5a89eaa621d2aa1a7@sentry.io/1545031',
  })
}

// https://github.com/turbolinks/turbolinks/issues/430#issuecomment-444767978
document.addEventListener('turbolinks:request-start', event =>
  event.data.xhr.setRequestHeader(
    'X-Turbolinks-Nonce',
    document.querySelector('meta[name=csp-nonce]').content,
  ),
)

require.context('../images', true)
// Support component names relative to this directory:
require('react_ujs').useContext(require.context('components', true))
