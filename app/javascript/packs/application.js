import 'application/application.scss'

import 'controllers'
import * as Sentry from '@sentry/browser'
require('@rails/ujs').start()
require('turbolinks').start()

window.Sentry = Sentry // Make it available globally
if (process.env.NODE_ENV === 'production') {
  Sentry.init({
    dsn: 'https://5e07926b621741b5a89eaa621d2aa1a7@sentry.io/1545031',
  })
}

require.context('../images', true)
// Support component names relative to this directory:
require('react_ujs').useContext(require.context('components', true))
