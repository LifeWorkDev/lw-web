const path = require('path')

module.exports = {
  env: {
    browser: true,
    es6: true,
    node: true,
  },
  extends: [
    'plugin:prettier/recommended',
    'eslint:recommended',
    'plugin:import/errors',
    'plugin:import/warnings'
  ],
  globals: {
    Atomics: 'readonly',
    SharedArrayBuffer: 'readonly'
  },
  parser: 'babel-eslint',
  parserOptions: {
    ecmaVersion: 2018,
    sourceType: 'module'
  },
  plugins: ['sort-imports-es6-autofix'],
  rules: {
    'prettier/prettier': [
      'error',
      {
        semi: false,
        singleQuote: true,
        trailingComma: 'all'
      }
    ],
    camelcase: ['error', { properties: 'never' }],
    'import/first': 'error',
    'import/no-duplicates': 'error',
    'no-console': 'off',
    'no-var': 'error',
    'no-debugger': 'off',
    'no-unused-vars': ['error', { ignoreRestSiblings: true }],
    indent: ['error', 2],
    'linebreak-style': ['error', 'unix'],
    'comma-dangle': ['error', 'always-multiline'],
    quotes: [
      'error',
      'single',
      {
        avoidEscape: true,
        allowTemplateLiterals: false
      }
    ],
    semi: ['error', 'never'],
    'sort-imports-es6-autofix/sort-imports-es6': [
      'error',
      {
        ignoreCase: true,
        memberSyntaxSortOrder: ['none', 'all', 'single', 'multiple']
      }
    ]
  },
  settings: {
    'import/resolver': {
      webpack: {
        config: path.resolve('config/webpack/development.js')
      }
    }
  }
}
