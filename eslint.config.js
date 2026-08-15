import ripple from '@tsrx/eslint-plugin';

export default [
  ...ripple.configs.recommended,
  {
    ignores: ['**/dist/**', '**/node_modules/**', 'e2e/**', 'playwright-report/**'],
  },
];
