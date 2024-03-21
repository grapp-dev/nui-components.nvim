module.exports = {
  parser: '@typescript-eslint/parser',
  parserOptions: {
    sourceType: 'module',
  },
  plugins: ['@typescript-eslint', 'import', 'react'],
  extends: ['plugin:react/recommended'],
  settings: {
    react: {
      version: 'detect',
    },
  },
  rules: {
    'import/extensions': ['error', 'never'],
    'no-shadow': 'off',
    '@typescript-eslint/no-shadow': 'warn',
    'linebreak-style': 'error',
    'react/display-name': 'off',
    'react/prop-types': 'off',
    'react/react-in-jsx-scope': 'off',
  },
}
