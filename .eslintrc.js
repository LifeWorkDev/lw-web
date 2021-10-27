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
    'plugin:react/recommended',
    'plugin:import/errors',
    'plugin:import/warnings',
  ],
  globals: {
    Atomics: 'readonly',
    SharedArrayBuffer: 'readonly',
  },
  parser: '@babel/eslint-parser',
  parserOptions: {
    ecmaVersion: 2018,
    sourceType: 'module',
  },
  plugins: ['sort-keys-fix'],
  rules: {
    'prettier/prettier': ['error', {}],
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
    'react/forbid-foreign-prop-types': 'error',
    'react/jsx-fragments': ['error', 'syntax'],
    'react/no-typos': 'error',
    semi: ['error', 'never'],
    'sort-keys-fix/sort-keys-fix': [
      'error',
      'asc',
      {
        caseSensitive: false,
        natural: true,
      },
    ],
  },
  settings: {
    'import/resolver': {
      webpack: {
        config: path.resolve(`config/webpack/test.js`),
      },
    },
    react: { version: 'detect' },
  },
}
