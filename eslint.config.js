import ripple from '@tsrx/eslint-plugin';

export default [
  ...ripple.configs.recommended,
  {
    ignores: ['**/dist/**', '**/node_modules/**', 'e2e/**', 'playwright-report/**'],
  },
  {
    // ripple/prefer-oninput 只做字符串层面的 JSX 属性名匹配（不区分原生 DOM 元素与
    // 自定义组件），下面这些文件里的 onChange 全部是 lotus 组件（Input/TextArea/
    // Switch/Tabs）自己定义的公开 prop，对齐 Semi Design 官方同名 prop 语义，不是
    // 原生 DOM 元素上误写的合成事件。逐一核实过，不是原生 DOM onChange 误用。
    //
    // 本想在触发点用 eslint-disable-next-line 行内注释更精确地关闭，但
    // @tsrx/eslint-parser@0.3.119 的 parseForESLint 对 .tsrx 文件返回的
    // comments 数组始终为空（用 node 直接调用该 API 验证过），ESLint 读不到任何
    // 指令注释，行内禁用在 .tsrx 文件里完全不生效，只能退而求其次按文件路径关闭。
    files: [
      'apps/docs/src/demos/input/input/basic.tsrx',
      'apps/docs/src/demos/input/input/controlled.tsrx',
      'apps/docs/src/demos/input/input/textarea-basic.tsrx',
      'apps/docs/src/demos/input/switch/basic.tsrx',
      'apps/docs/src/demos/input/switch/controlled.tsrx',
      'apps/docs/src/demos/navigation/tabs/basic.tsrx',
      'apps/docs/src/demos/feedback/skeleton/basic.tsrx',
      'apps/playground/src/App.tsrx',
      'packages/ripple/src/input/form/field.tsrx',
    ],
    rules: {
      'ripple/prefer-oninput': 'off',
    },
  },
];
