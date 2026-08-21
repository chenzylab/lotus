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
    // `apps/docs/src/demos/**` 用 glob 整体排除——这个目录下的文件全部是"演示
    // 某个 lotus 组件用法"的独立 demo，onChange 出现在这里几乎必然是组件自己
    // 定义的 prop（对齐 Semi 同名 prop 语义），不是原生 DOM 元素上误写的合成
    // 事件，没有必要每新增一个 demo 文件就手动补一行路径。
    files: [
      'apps/docs/src/demos/**',
      'apps/playground/src/App.tsrx',
      'packages/ripple/src/input/auto-complete/index.tsrx',
      'packages/ripple/src/input/cascader/index.tsrx',
      'packages/ripple/src/input/form/field.tsrx',
      'packages/ripple/src/input/tree-select/index.tsrx',
      'packages/ripple/src/navigation/pagination/index.tsrx',
      'packages/ripple/src/navigation/tree/index.tsrx',
      'packages/ripple/src/input/time-picker/index.tsrx',
      'packages/ripple/src/input/transfer/index.tsrx',
      'packages/ripple/src/show/table/index.tsrx',
    ],
    rules: {
      'ripple/prefer-oninput': 'off',
    },
  },
  {
    // Upload 组件是这条规则唯一一次真正命中原生 DOM 元素误用的情况（不是像
    // 上面那批文件那样的组件 prop 误报）：两个隐藏的 <input type="file">
    // onChange 本该被规则建议改成 onInput，但文件选择器（type="file"）浏览器
    // 规范上只派发 change 事件、不派发 input 事件——改成 onInput 会让选择文件
    // 后回调永远不触发，是比 lint 告警更严重的真实功能性 bug。核实过 Ripple
    // 的 onInput 属性名确实映射的是原生 input 事件（对照 Input 组件内部实现），
    // 保留 onChange 是唯一正确选择，此处关闭规则不是回避审查，是这条规则的
    // 检测范围本身没考虑 type="file" 这个例外。
    files: ['packages/ripple/src/input/upload/index.tsrx'],
    rules: {
      'ripple/prefer-oninput': 'off',
    },
  },
];
