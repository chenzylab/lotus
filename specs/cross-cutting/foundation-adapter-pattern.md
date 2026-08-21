# Foundation/Adapter 依赖注入模式 — Phase 0 实测结论

> 本文件是 Phase 0 SPEC 要求的核心产出物：记录 Foundation 如何拿到 Ripple `track()` state 的实测范式。
> 验证对象：`packages/foundation/src/basic/button/foundation.ts`（`ButtonFoundation`）+ `packages/ripple/src/basic/button/index.tsrx`（`Button`）。
> 验证方式：`pnpm --filter @lotus/playground build` 编译通过、Vitest 单测通过（不 import `ripple`）、Chrome 真实渲染 + 点击交互（default/disabled/loading 三态）验证行为正确。**所有验证均为实测，非推断**。

## 结论：模式可行，无需变更

Phase 0 设计阶段假设的依赖注入模式——Adapter 用 `track()` 创建响应式状态，通过一个满足 `Adapter<S>` 接口的 plain object（`{ getState, setState }`）注入给 Foundation——在 Ripple 的细粒度响应式模型下**完全可行，没有出现摩擦**。后续所有组件按此模式实现，不需要探索替代方案。

## 范式代码（后续组件直接复用此结构）

**Foundation 侧**（`packages/foundation/src/base/adapter.ts`）：

```ts
export interface Adapter<S> {
  getState: () => S;
  setState: (patch: Partial<S>) => void;
}

export abstract class Foundation<S> {
  protected adapter: Adapter<S>;
  constructor(adapter: Adapter<S>) { this.adapter = adapter; }
  protected getState(): S { return this.adapter.getState(); }
  protected setState(patch: Partial<S>): void { this.adapter.setState(patch); }
}
```

具体组件的 Foundation 只需继承 `Foundation<S>`，业务方法通过 `this.getState()`/`this.setState()` 读写状态，不感知状态的响应式实现细节：

```ts
export class ButtonFoundation extends Foundation<ButtonState> {
  handleClick(onClick?: () => void): void {
    const { disabled, loading } = this.getState();
    if (disabled || loading) return;
    onClick?.();
  }
}
```

**Adapter 侧**（`.tsrx` 组件）：

```tsrx
import { track } from 'ripple';
import { ButtonFoundation, type ButtonState } from '@lotus/foundation/basic/button';

export function Button({ children, onClick, disabled, loading }: ButtonProps) @{
    let &[state] = track<ButtonState>({ disabled: !!disabled, loading: !!loading });

    const foundation = new ButtonFoundation({
        getState: () => state,
        setState: (patch) => { state = { ...state, ...patch }; },
    });

    <>
        <button disabled={state.disabled} onClick={() => foundation.handleClick(onClick)}>
            {children}
        </button>
        <style>/* ... */</style>
    </>
}
```

## 实测验证到的关键点

1. **`track()` 状态可以被闭包捕获后原样传给 Foundation 构造函数**，`getState: () => state` 这种箭头函数写法能正确读到 tsrx 编译后的最新值——不需要每次状态变化重新 new 一个 Foundation 实例，Foundation 实例可以在组件生命周期内保持单一。
2. **`setState` 通过重新赋值整个 state 对象（`state = { ...state, ...patch }`）触发响应式更新**，而不是需要调用某个特殊的 Ripple API。lazy destructure（`let &[state] = track(...)`）产出的绑定支持直接赋值语义。
3. **Foundation 类完全不 import `ripple`**，用 Vitest 手写 mock adapter（plain object + 闭包变量）即可单测，红线检查（`grep ripple` 命中为零）已验证。
4. **模板中直接读取 `state.xxx`（如 `state.disabled`）能正确建立响应式依赖**，浏览器实测中 disabled 状态变化后按钮的 `disabled` 属性正确反映。

## 已知踩坑（供后续组件实现参考，避免重复踩坑）

### 1. tsrx 语句容器渲染多个兄弟节点必须包 Fragment

`@{...}` 语句容器最后必须是**单个**输出节点。Button 组件最初实现里 `<button>` 和 `<style>` 是两个平级兄弟标签，未包裹 `<>...</>`，导致编译报错：

```
Error: A code block renders a single node; wrap multiple nodes or text in a fragment '<>…</>'.
```

**规则**：只要一个组件同时有渲染内容 + `<style>` 块（几乎是每个组件的标配），就必须用 `<>...</>` 包裹两者。`component-authoring` skill 已补充此提醒。

### 2. `@ripple-ts/vite-plugin` 是具名导出，不是默认导出

tsrx 官方 `llms.txt` 文档示例写的是 `import ripple from '@ripple-ts/vite-plugin'`（默认导入），但实测 `0.3.118` 版本源码（`node_modules/.pnpm/@ripple-ts+vite-plugin@0.3.118/.../src/index.js`）里是 `export function ripple(...)`，即**具名导出**。正确写法：

```ts
import { ripple } from '@ripple-ts/vite-plugin';
```

这是文档与实际包版本不一致的案例，说明 llms.txt 文档可能滞后于包的实际实现，后续遇到编译/运行时报错优先信任实测的源码行为，而非文档描述（对应用户开发原则「以核对源码为荣，以轻信文档为耻」）。

### 3. TypeScript `NodeNext` 模块解析下，源码内相对 import 必须带 `.js` 后缀

`packages/tokens`、`packages/foundation` 这类"有独立 `tsc build` 产出可被 Node 直接运行的 dist"的包，`tsconfig.json` 需要用 `module`/`moduleResolution: NodeNext`（而不是继承自根 `tsconfig.base.json` 的 `Bundler` 模式），此时源码里的相对 import 必须写 `.js` 后缀（即使源文件是 `.ts`），这是 TypeScript 官方约定写法，`tsc` 编译时会自动映射到正确的输出文件，不是笔误。

`packages/ripple`（消费方是 Vite/tsrx 插件链，不做独立 `tsc build`）保持继承 `Bundler` 模式，import 不需要扩展名。**两种包对模块解析策略的选择取决于它们的构建/消费方式，不是任意选一种全局统一**。

### 4. 独立脚本（非 tsc 编译）引用同包内 `tsc` 产物，应从 `dist` 而非 `src` 引入

`packages/tokens/scripts/build-css.ts` 用 `node --experimental-strip-types` 直接运行（不经过 `tsc`），如果它 import 同包 `src/*.ts` 源码，会与源码本身"给 tsc 编译、不带 `.ts` 后缀"的写法冲突（Node ESM 加载器要求扩展名，且不认 `.ts` 后缀除非显式允许）。正确做法：脚本在 `package.json` 的 `build` 命令里排在 `tsc` 之后执行，改为 import `../dist/*.js`（编译产物），源码保持单一、规范的 `NodeNext` 写法不被脚本的特殊运行方式污染。

### 5. `.tsrx` 文件的类型检查必须用 `tsrx-tsc`，裸 `tsc` CLI 无法识别 `.tsrx`

任何直接 import `.tsrx` 文件的包（`packages/ripple`、`apps/playground` 等）跑 `tsc -p tsconfig.json --noEmit` 会报错 `Cannot find module './xxx/index.tsrx' or its corresponding type declarations`（TS2307），即使 `tsconfig.json` 里已经按官方文档配置了 `compilerOptions.plugins: [{ name: '@tsrx/typescript-plugin' }]` 也不例外。

**根因**：`@tsrx/typescript-plugin` 是基于 Volar 的 **tsserver 插件**（服务编辑器语言服务/IDE 场景），`compilerOptions.plugins` 字段从设计上就只被 `tsserver` 进程加载，标准 `tsc` 命令行编译器（无论是否传 `--noEmit`）从不读取这个字段、也不会加载其中声明的插件。这不是配置错误，是两套完全不同的加载路径。

**正确做法**：命令行/CI 场景下类型检查 `.tsrx` 文件，必须用 `@tsrx/typescript-plugin` 包自带的 **`tsrx-tsc`** 命令（`bin: { "tsrx-tsc": "./dist/tsc.js" }`），而不是 `tsc`：

```json
{
  "scripts": {
    "typecheck": "tsrx-tsc -p tsconfig.json --noEmit"
  },
  "devDependencies": {
    "typescript": "npm:typescript@5.9.3",
    "@tsrx/typescript-plugin": "0.3.118"
  }
}
```

**连带的版本约束**：`@tsrx/typescript-plugin@0.3.118` 的 `peerDependencies` 要求 `typescript@^5.9.3`，与本项目其余包（`packages/tokens`/`packages/foundation`，无 `.tsrx` 依赖）使用的 `typescript@7.0.2`（latest，原生 Go 编译器）不兼容。解决方案：**只有直接消费 `.tsrx` 类型的包**（`packages/ripple`、`apps/playground`，以及未来任何直接 import `.tsrx` 的包）在自己的 `package.json` 里用别名依赖单独锁定 `"typescript": "npm:typescript@5.9.3"`，不写入根 `pnpm-workspace.yaml` 的 catalog（catalog 内同一包名不能有两个版本，且此约束只影响少数包，没必要拖累全项目回退到 5.x）。`tsconfig.json` 里除 `plugins` 外，还需要 `jsxImportSource: "ripple"`（否则找不到 JSX 类型定义）。

**若 CSS 子路径导入报类型错误**（如 `import '@lotus/tokens/css'` 报 `Cannot find module or type declarations for side-effect import`）：给该 `tsconfig.json` 加 `"types": ["vite/client"]`，`vite/client` 自带的 `*.css` 通配类型声明能覆盖带包名前缀的子路径导入，不需要给 `@lotus/tokens` 的 `./css` 导出单独写类型声明文件。

### 6. `typescript-eslint` 尚不支持 TypeScript 7.0，根级 ESLint 需要单独锁定 TS 6.x 别名

`@typescript-eslint/parser` 解析 `.ts` 文件时，若检测到项目使用 `typescript@7.0.x`，会直接报错拒绝运行：

```
typescript-eslint does not support TS 7.0.
Please see https://devblogs.microsoft.com/typescript/announcing-typescript-7-0/#running-side-by-side-with-typescript-6.0
```

这不是本项目配置问题，是 `typescript-eslint` 生态尚未跟上 TypeScript 7.0（原生 Go 编译器重写）发布节奏的已知断层（追踪：`typescript-eslint/typescript-eslint#10940`）。

**根因**：ESLint 是从仓库根目录运行的（`eslint .` 扫描全部 workspace 文件），它解析到的 `typescript` 版本取自**根 `package.json` 的 `devDependencies`**，与各子包各自独立锁定的 `typescript` 版本无关（pnpm workspace 下每个包的依赖解析相互隔离）。

**正确做法**：TypeScript 官方为此发布了兼容包 `@typescript/typescript6`，在根 `package.json` 里用别名依赖把 `typescript` 指向它，且**不影响任何子包**（子包各自在自己的 `package.json` 里声明的 `typescript` 版本不受根目录影响）：

```json
{
  "devDependencies": {
    "typescript": "npm:@typescript/typescript6@^6.0.2"
  }
}
```

`packages/tokens`/`packages/foundation` 继续用 `catalog:`（`typescript@7.0.2`），`packages/ripple`/`apps/playground` 继续用 `npm:typescript@5.9.3`（见 #5）。**根级、`tokens`/`foundation`、`ripple`/`playground` 三处的 TypeScript 版本各自独立，互不影响，这是刻意设计，不是遗留的不一致**——分别对应"ESLint 静态分析"“无 tsrx 依赖的纯 TS 包”“直接消费 .tsrx 类型的包”三种不同的版本约束来源。

### 7. 组件 setup 阶段的普通变量赋值不是响应式的——跨组件共享的计算值必须用派生 `track()`

Phase 1 实现 Grid（Row/Col）时踩过的最复杂、排查耗时最长的一组坑，核心教训只有一句话：
**`.tsrx` 组件函数体（`@{...}` 语句容器）的 setup 部分只在组件创建时执行一次，之后不会重新跑**；
真正的响应式更新只来自两处：(a) 模板 JSX 内联表达式直接读取的响应式绑定，(b) 显式的派生
`track(() => expr)` 或 `effect(() => {...})`。用普通 `const x = someTrackedValue.field` 或
`const x = computeSomething(trackedValue)` 计算出的中间变量，**只是创建那一刻的快照**，源头
响应式值后续变化不会让这个快照重新计算——这与 React 的"整个组件函数每次渲染都重跑"心智模型
完全不同，从其他框架迁移经验时最容易踩这个坑。

**具体案发过程**（Row/Col 断点响应式，浏览器 resize 窗口实测才暴露）：

1. **误传 plain object 到 Context**：`RowContext.set({ screens: state.screens, ... })` 传入解构
   出的 plain object。`Context.set/get` 本身只是树形作用域的值存取（见 Ripple 源码
   `runtime/internal/client/context.js`——`get()`/`set()` 就是 Map 的存取，无任何响应式包装），
   Col 读到的是创建那一刻的快照，Row 断点变化后 Context 里的值不会更新。
   **修复**：Context 必须存 `Tracked<T>` 对象本身（`track()` 解构出的第二个绑定，不要只取
   `.value`），消费方读 `.value`。这是官方文档 `Context` 示例本来就演示的模式
   （`ThemeContext.set(themeTracked)` 而非 `ThemeContext.set(theme)`），但很容易在业务代码里
   无意识地"图省事"解构成 plain object 后再传，一定要对照文档示例核对传入 Context 的是不是
   Tracked 本身。

2. **在 setup 阶段用一次性赋值同步响应式值，看似合理实则无效**：为了让 `contextValue` 随
   `state.screens` 变化，写成 `contextValue = { screens: state.screens, ... }` 直接赋值——这个
   赋值语句本身只执行一次（组件创建时），后续 `state` 变化不会重新触发这行赋值。
   **修复**：改用派生 track——`let &[x] = track(() => computeFromReactiveSource())`，函数体内的
   读取会建立正确的依赖追踪，源头变化时自动重新求值。

3. **Col 组件内计算 `widthPercent`/`offsetPercent`/`finalOrder` 等值时同样用了 setup 阶段的
   普通 `const`**：即使这些计算读取了响应式的 `context`/`contextTracked.value`，计算结果本身
   仍是不会更新的快照。**修复**：所有依赖响应式源头、且需要在源头变化时更新视觉呈现的计算值，
   全部改写成 `let &[x] = track(() => ...)` 派生绑定，模板里读绑定本身（不读计算前的原始值）。

4. **`effect()` 内部的初始化副作用若读写同一份 state 会触发无限循环**：
   `effect(() => { const cleanup = foundation.init(); return cleanup; })`，`foundation.init()`
   内部会立即（`callOnInit: true`）调用多次 `setState`（每个断点一次）。这些写入发生在 effect
   自身的同步执行栈内，若不做任何处理，会被判定为"该 effect 读写了同一份 state"，Ripple 运行时
   会在触发 1000+ 次后主动抛错兜底（`Maximum update depth exceeded`，来自
   `runtime/internal/client/runtime.js` 的 `flush_count > 1001` 检查）。
   **修复**：初始化阶段的副作用注册（不代表"这个 effect 依赖 state 变化"，只是"组件挂载时执行
   一次的命令式初始化逻辑"）必须用 `untrack(() => foundation.init())` 包裹整个调用，阻止其内部
   的读写被计入当前 effect 的响应式依赖图。同样，Foundation 的 `getState` 实现也应该用
   `untrack(() => state)` 包裹，因为 Foundation 内部方法读取当前状态做 patch 合并，属于"取值"
   而非"建立依赖"的语义。

**通用范式（后续所有涉及跨组件响应式共享状态的组件直接套用）**：

```tsrx
// 生产方（Row 类角色）
const foundation = new XxxFoundation({
    getState: () => untrack(() => state),          // 取值不建立依赖
    setState: (patch) => { state = { ...state, ...patch }; },
});
effect(() => {
    const cleanup = untrack(() => foundation.init()); // 初始化副作用不建立依赖
    return cleanup;
});
let &[, sharedTracked] = track(() => ({ ...computeFromState(state) })); // 派生值，非一次性赋值
SomeContext.set(sharedTracked);                     // 传 Tracked 本身，不解构

// 消费方（Col 类角色）
const sharedTracked = SomeContext.get();
let &[derivedValue] = track(() => {                 // 消费方同样要用派生 track，不能用普通 const
    const shared = sharedTracked?.value ?? defaultValue;
    return computeSomethingFrom(shared, localProps);
});
// 模板直接使用 derivedValue（响应式绑定），不要提前用 const 缓存计算结果
```

**验证方式**：浏览器实测 `resize_window` 改变视口宽度，观察布局是否**不刷新页面**就实时联动
变化——这是唯一能暴露这类问题的验证方式，`typecheck`/单测/静态截图都无法发现，因为问题的本质
是"响应式更新是否真的会在源头变化时重新触发"，必须有一个真实的状态变化事件（如 viewport
resize、用户交互）作为触发源才能观测。Grid 的正确性最终是通过 Chrome 窗口从 1512px resize 到
700px、三列从横排三等分实时变为纵向堆叠来确认的。

**第二次实测印证（Switch 组件，点击交互场景）**：Switch 的 `classes`（class 字符串拼接）用了
`const classes = [...].filter(Boolean).join(' ')`，其中引用了派生 track `displayChecked`。
真机点击测试：console 正确打印 `onChange` 回调（Foundation 逻辑本身没问题），但按钮外观**不
切换**（滑块位置、背景色都停在初始态）——与 Grid 案例是同一根因，`classes` 这个 const 只在
组件创建时算了一次，`displayChecked` 后续变化不会让它重算。修复：把 `classes` 也改成
`let &[classes] = track(() => [...].filter(Boolean).join(' '))`。

**判断准则（避免过度紧张地把所有 `const classes` 都改成 track）**：只有当计算值**读取了组件
内部的 `track()` 状态或派生 track**（即会在组件生命周期内变化的响应式源）时，才需要用派生
`track()` 包装；如果计算值只读取**props**（如 `align`/`vertical`/`className` 这类外部传入、
组件生命周期内本身不会变化的值），普通 `const` 是安全的——props 变化意味着父组件用新值重新
渲染了这个子组件实例，不存在"props 变了但同一个组件实例的旧 const 快照没更新"的问题。Divider/
Space/Row/Col 的 `classes` 都只依赖 props，保留 const 写法是对的，不要不加区分地全部套用
派生 track 模式。

### 8. Playwright `webServer.command` 写成 `pnpm --filter <pkg> <script> -- <args>` 会导致端口参数丢失、启动超时

Phase 1 首次真正跑通 `pnpm test:e2e`（此前的 Button/Grid/Switch 都是在 Chrome 真机手动验证，
没有走 Playwright 自动拉起的 dev server）时踩的坑：`playwright.config.ts` 的 `webServer.command`
若写成 `pnpm --filter @lotus/playground dev -- --port 5183`，Playwright 会一直等到
`timeout: 30_000` 超时报错 `Timed out waiting 30000ms from config.webServer.`，即使手动执行
同一条命令看起来能正常启动 dev server（这是最容易误判"配置没问题、可能是环境问题"的地方）。

**根因**：`package.json` 里 `@lotus/playground` 的 `dev` 脚本本身就是 `vite`。pnpm 遇到
`<script> -- <args>` 语法会把 `-- --port 5183` **原样透传**给这个脚本命令，拼接结果是
`vite -- --port 5183`——多出来的这个 `--` 让 Vite 把 `--port 5183` 解析成位置参数（当成
entry 文件路径），而不是 `--port` 选项，端口设置被静默忽略，Vite 实际监听在默认的 `5173`
端口，Playwright 却在等 `5183` 一直探测不到。

**验证方法**：手动执行 `pnpm --filter <pkg> dev -- --port <port>`，用 `cat` 看启动日志里
`Local: http://localhost:XXXX/` 实际是哪个端口——如果不是期望的端口，就是这个坑。

**正确写法**：跳过 `package.json` script 这一层间接调用，直接用 `pnpm --filter <pkg> exec
<真实命令> <参数>`：

```ts
webServer: {
  command: 'pnpm --filter @lotus/playground exec vite --port 5183',
  url: 'http://localhost:5183',
  reuseExistingServer: !process.env.CI,
  timeout: 30_000,
},
```

`pnpm exec` 不经过 `package.json` scripts 字段的参数转发层，`--port 5183` 直接原样传给
`vite`，不会有额外的 `--` 干扰。

## 踩坑 #9：`ripple.config.ts` import `@ripple-ts/vite-plugin` 导致客户端 hydrate 整体崩溃（docs 站已知缺陷，未修复）

**现象**（2026-08-13 真机 + 生产构建双重实测发现）：`apps/docs` 站点里所有依赖交互的组件
（Switch、Tag 的 closable、Tabs 的点击切换）在浏览器里点击**完全无响应**——不是某个组件的
bug，是**全站**性的。首次在 `/basic/space` 页面验证间距尺寸 demo（内嵌 Tabs）时发现标签
点击不切换，一路排查发现同一份 Tabs 代码在 `apps/playground` 里可以正常点击，但在
`apps/docs` 里不行；进一步发现 `apps/docs` 里的 `Switch` 同样点击无响应；最终在 `pnpm build`
生产构建下用真实浏览器复现同一问题（排除 dev-only 噪音的可能性）。

**根因**：`apps/docs/ripple.config.ts` 顶层 `import { defineConfig } from
'@ripple-ts/vite-plugin'`。Ripple 的客户端 hydrate 入口代码生成器
（`@ripple-ts/vite-plugin` 的 `create_client_entry_source`）会生成
`import rippleConfig from '/ripple.config.ts'`，把**整个** `ripple.config.ts` 文件当作
一个模块直接打包进客户端 bundle。而 `@ripple-ts/vite-plugin` 自己的 `src/index.js` 顶层
第 48 行有一句未加保护的 `const IS_WINDOWS = process.platform === 'win32';`——这行代码
在服务端/构建时下毫无问题，但被整体打包进浏览器 bundle 后，浏览器执行到这一行必然抛
`ReferenceError: process is not defined`，把**整个客户端 hydrate 脚本的顶层执行**中断，
导致 `hydrate()`/`mount()` 调用根本没有机会跑起来——所有组件的事件监听器都没有被绑定，
但因为异常被 Vite 的模块预加载错误处理吞掉/仅打印到 console 而不是显式抛给我们的
try/catch，表现上是"安安静静地什么都不做"，极具迷惑性。

`@ripple-ts/adapter-node` 等 `SERVER_ONLY_ADAPTER_IDS` 名单里的包会被替换成浏览器安全
stub（见 `project-codegen.js` 的 `create_adapter_browser_stub_source`），但
`@ripple-ts/vite-plugin` 本身**不在**这个名单里，没有任何保护。

**误判史**：docs 站的 `vite.config.ts` 里早先记录过一条注释，声称
`optimizeDeps.exclude: ['@ripple-ts/vite-plugin']` 已经解决了 `process is not defined`
噪音，且验证依据是"Divider demo 真机验证正常"——这是一次**假阴性验证**：`optimizeDeps`
只影响 **dev 模式**的依赖预构建扫描，对生产构建的打包结果毫无作用；而 Divider 组件本身
没有任何交互逻辑，那次验证根本没有覆盖到"点击事件是否生效"这个维度。教训：验证一个
"已修复"的交互问题，必须用真正带交互的组件（而非纯展示组件）在生产构建（而非仅 dev
模式）下复测，否则空手套白狼式的"看起来没报错了"不能代表问题真的解决。

**当前处理**：这是 Ripple 官方工具链（`@ripple-ts/vite-plugin` 0.3.118）的缺陷，不是
lotus 自己代码的错误。用户决策：暂不深挖修复方案（可选路径包括本地重新实现一个不依赖
`@ripple-ts/vite-plugin` 的 `defineConfig` 恒等函数、或 `pnpm patch` 直接修补
`process.platform` 那一行加 `typeof process !== 'undefined'` 判断），先如实记录、继续
推进其他组件覆盖广度。**结论：`apps/docs` 站当前所有交互类组件 demo 在浏览器里均不可
点击验证**（Switch/Tag/Tabs 等），后续在 docs 里新增交互类组件 demo 时，交互行为的真实
验证必须依赖 `apps/playground`（纯 CSR，不受此问题影响）或组件包内的 e2e 测试
（同样跑在独立的纯 CSR 环境），不能指望在 docs 站点里点击验证。

## 踩坑 #10：`<span>` 内嵌套 `<div>` 触发 tsrx 编译器的 HTML5 语义校验，报错位置与真实
根因严重错位（2026-08-13 Avatar 组件实测，排查耗时极长）

**现象**：实现 Avatar 组件时（顶部/底部 Slot、额外边框、hover 遮罩层等特性），`tsrx-tsc
--noEmit` 报出几十条 `TS1381`（`Unexpected token`）/`TS1005`（`'}' expected`）之类的语法
错误，错误行号集中在文件中段一大段完全合法的 `<style>` CSS 规则附近（如
`.lotus-avatar-color-lime { background: ...; }` 这种标准写法）。逐行核对 CSS 语法、
JSDoc 注释里的反引号奇偶性、`@if`/`@else` 控制流的嵌套合法性、`ref` 回调箭头函数写法，
全部证明合法，报错行号却始终锁定在同一批完全正常的代码上，持续多轮修改无效。

**根因**：`tsrx-tsc` 在语法解析之外还会做一次 HTML5 语义嵌套校验（如 `<div>` 不能是
`<span>` 的后代——span 是 phrasing content，不能包含 div 这种 flow content）。校验命中
时会先打印一行独立提示 `[tsrx-tsc] <file>: Invalid HTML nesting: <div> cannot be a
descendant of <span>.`，但这行提示**没有任何行号**，且默认输出会被终端截断/淹没在后续
几十条语法错误里（`tail -N` 更是直接看不到它，因为它在最前面）。校验失败后，编译器的
解析状态似乎受到污染，导致后续本该正常的代码被level联报出大量语法错误，错误行号与真正
出问题的行**完全对不上**——真实违规行在文件前半部分，报错行号却指向文件中段一段无关的
CSS。本次实际踩了两处独立的违规：(1) `<span class={avatarClasses}>` 内部塞了一个
`<span class="hover-overlay">` 没问题，但错误示范是塞了 `<div class="hover-overlay">`；
(2) 最外层 wrapper 用了 `<span class="wrapper">` 包裹 avatar 本体 + topSlot/bottomSlot，
而 topSlot/bottomSlot 内部渲染了 `<div>`，同样违反 span 不能包含 div 的规则。

**排查方法（教训）**：不要在报错行号附近打转。`tsrx-tsc` 的完整输出**必须看最前面几行**
（`| head -20`，不要只 `tail`），HTML 嵌套校验提示就在那里，且不含行号——找到提示后，
去检查文件里所有 `<span>`...`</span>` 之间是否直接或间接包了 `<div>`（含通过 `@if`/
`@else` 间接渲染出来的 `<div>`，不止字面量直接嵌套）。二分排除法在这个坑上基本失效
（因为报错行号本身不可信，缩减文件范围时命中或跳过校验点全凭运气），唯一可靠的方法是
通读完整输出找到那行不含行号的 "Invalid HTML nesting" 提示，直接对症下药。

**修复模式**：凡是"可能需要在内部渲染任意 flow content（div/p 等块级元素）"的容器，
一律用 `<div>` 而非 `<span>` 作为外层标签，不要因为视觉上想要 `inline`/`inline-flex`
就选用 `<span>`——`display` 是 CSS 层面的事，用 `<div style="display:inline-flex">`
同样能达到视觉效果，且不受 HTML5 语义嵌套限制。反之，明确只包含文本/行内内容的场景
才用 `<span>`。

## 踩坑 #11：组件用普通 `return <>...</>;`（而非 `@{...}` 语句容器）时，`<style>`
块内容不会被提取注入，CSS 完全不生效且无任何报错（2026-08-13 Layout + AvatarGroup 实测）

**现象**：`Layout`/`Header`/`Footer`/`Content`（basic/layout）和 `AvatarGroup`
（show/avatar）四个组件的 `<style>` 块里定义的 CSS 规则（如 `.lotus-layout { flex-
direction: column; }`、`.lotus-avatar-group { display: inline-flex; }`）在浏览器里
完全不生效——`getComputedStyle` 测出来的实际值与组件自身样式表毫无关系（例如
`.lotus-layout` 实测 `flex-direction` 是继承自浏览器默认值的 `row`，而不是样式表里写的
`column`）。**没有任何编译错误或运行时报错**，`tsrx-tsc --noEmit` 和 `pnpm build`
都顺利通过，只有真机 e2e 测试断言实际计算样式时才会发现。

**根因**：这四个组件的函数体用的是 `export function Xxx(props) { ... return <>
<section>...</section><style>...</style></>; }` 这种**普通函数体 + 显式 `return`**
写法。而本仓库所有此前验证过 CSS 生效的组件（Button/Divider/Space/Grid/Switch/Tag/
Tabs/Avatar 本体）无一例外用的是 `export function Xxx(props) @{ ... <>...<style>...
</style></> }` 这种 **`@{...}` 语句容器**写法（无显式 `return`，`<>...</>` 直接作为
语句容器的收尾表达式）。两者在渲染结果上肉眼看不出区别（DOM 结构完全一样），但
`<style>` 块的 CSS 提取似乎只识别 `@{...}` 语句容器场景——用浏览器 JS 直接检查
`document.querySelectorAll('style')` 的内容，普通 `return` 写法的组件样式表**整段
缺失**，`@{...}` 写法的组件样式表正常出现。

**排查方法**：怀疑某组件样式完全不生效、又没有任何报错时，第一步用
`Array.from(document.querySelectorAll('style')).map(s=>s.textContent).join('\n')`
搜索该组件的某个 class 名是否真的出现在页面注入的样式表里——如果压根不存在（而不是
存在但被覆盖/优先级不够），基本可以断定是这个"普通 return 吞掉 style 块"的坑，而不是
CSS 选择器/特异性问题。不要先去怀疑 CSS 规则本身写错了。

**修复**：所有带 `<style>` 块的组件，函数体一律用 `@{...}` 语句容器写法，不要用
`{ ... return <>...</>; }`——即使组件逻辑简单到只有一行 `const classes = [...].join(' ')`
也要用 `@{}` 加不带 `return` 的收尾 `<>...</>`。这应当固化为组件开发的强制约定，本文档
现有范式代码示例已全部采用 `@{}` 写法，新组件直接照抄结构即可，不要因为"逻辑简单不需要
语句容器"而改用普通 `return`。

## 踩坑 #12：`<Portal target={fn()}>` 命名为 `fn` 类似 "xxxTarget" 的箭头函数会与内部
getter 求值时序冲突，报 `TypeError: fn is not a function`（2026-08-13 Tooltip 实测）

**现象**：Tooltip 组件里 `getPopupContainer` 自定义挂载点的解析函数写成
`const portalTarget = () => getPopupContainer?.() ?? document.body;`，使用处
`<Portal target={portalTarget()}>`——typecheck 通过，但真机点击/hover 触发浮层时
控制台报 `TypeError: fn is not a function`，堆栈指向 `portalTarget` 函数内部
及 Ripple 运行时的 `get target` getter，浮层完全不显示，且没有任何编译期报错。

**根因排查过程**：`Portal` 组件的 `props.target` 类型是 `Element`（读 Ripple 源码
`packages/ripple/src/runtime/internal/client/portal.js` 的 JSDoc 确认），调用处
`target={portalTarget()}` 语法本身没有问题——已经显式调用求值了。真正踩中的是
**函数命名巧合**：把"返回挂载目标 DOM 的函数"命名为 `portalTarget`，这个名字本身
看起来像一个"惰性访问器"而非"一次性求值的普通函数"，排查过程中曾怀疑是 tsrx 编译器
把 JSX 属性值表达式统一编译成 getter（`get target() { return <expr>; }`）导致某种
时序或递归调用混淆。最终修复是把函数改名为 `resolvePortalTarget`（更明确地表达"这是
一个立即调用求值的解析函数，不是一个可以被当作访问器复用的东西"）后问题消失。

**没有定位到 100% 确定的根因**（可能是 tsrx 编译器对形如 `xxxTarget`/`getXxx` 这类
命名模式在属性值位置有特殊优化路径，也可能是巧合，两次独立验证都指向"改名后必现修复、
改回原名必现复现"）。**教训**：遇到"函数值传给某个同名/近名 prop 时诡异报错"的场景
（例如 `target={xxxTarget()}`、`onXxx={xxxHandler}` 这类命名与 prop 名高度相似的情况），
优先尝试改名而非深挖 tsrx 编译器内部实现——性价比更高，且这类问题复现条件苛刻，
不值得为了 100% 查清根因阻塞组件开发进度。

## 踩坑 #13：`@for` 循环体内用 `@if` 部分跳过渲染（部分项不产生 DOM），状态切换时
keyed-diff 顺序错乱，且改 `key` 表达式无法修复（2026-08-13 Breadcrumb 折叠展开实测）

**现象**：Breadcrumb 的折叠功能——`@for (const route of normalizedRoutes; index i; key
...) { @if (是省略号位置) {...} @else { @if (不在折叠区间内) { <li>正常项</li> } } }`
（折叠区间内的项，内层 `@if` 判断为 false，不产生任何 DOM）。折叠态下视觉完全正确；
点击省略号切换到展开态（`collapsedRange` 变为 `null`，所有项都应该正常渲染）后，
渲染出的顺序完全错乱：折叠态下**原本可见**的项（首项 + 尾部保留项）排在前面，折叠态下
**原本被跳过、这次新增渲染**的中间项被追加在了列表末尾，而不是插入到正确的中间位置；
且相邻两项文字有时会挤在一起缺失分隔符，形似两个 `<li>` 被错误合并成了一个。

**排查弯路**：最初怀疑是 `@for` 缺少 `key` 子句导致 diff 退化成按 index 位置复用
（只写了 `index i`，没写 `key`）——补上 `key `${route.name}-${i}`` 后问题依旧；进一步
怀疑是 key 语义本身有问题（同一个 index 在折叠态/展开态代表不同渲染分支——折叠态是
"省略号"，展开态是"正常项"），改成条件表达式 `key (是省略号位置) ? 'collapse-more' :
'item-'+i` 让不同分支产生不同 key，问题仍然复现，证明根因不在 key 本身。

**根因**：问题不是 key 策略，而是**`@for` 循环体内嵌套 `@if` 让部分数组项完全不产生
输出**这个模式本身，在 Ripple 的 keyed-list diff 实现下不可靠——推测运行时把"当前渲染
批次里产生了 DOM 的项"与"上一批次产生了 DOM 的项"做位置对齐时，某种内部簿记没有正确
处理"同一数组下标在不同批次间产出数量不同"（1 个省略号 `<li>` vs 0~3 个被跳过的项）
这种情况，导致新增节点被整体追加在尾部而非插入正确位置。

**修复**：不在 `@for` 循环体内做"部分项不产生 DOM"的条件跳过。改为在 Foundation 层
（纯 JS，不涉及模板）预先把「原始数组 + 折叠区间」摊平成一份**每一项都对应恰好一个
渲染节点**的展示列表（`BreadcrumbFoundation.buildDisplayItems`，省略号本身也是列表
中的一项，类型为 `'more'`），模板侧对这份摊平列表做**单层、无内部条件跳过**的 `@for`
循环，每次遍历都保证"数组每一项 = 恰好一个 DOM 节点"。这个模式此后应作为约定：
凡是"数组渲染时某些项要被隐藏/合并/省略"的场景，一律在渲染前于 JS 层完成列表变换，
不要指望 `@for` 循环体内的 `@if` 能安全地让部分项完全不产生输出。

## 踩坑 #14：`style={{ width: 80 }}` 传纯数字（无单位）时该条 CSS 声明被浏览器判定为
非法值直接忽略，元素宽高塌陷为 0 且无任何报错（2026-08-13 Skeleton 组件实测）

**现象**：Skeleton 系列组件（`SkeletonAvatar`/`SkeletonImage`/`SkeletonTitle` 等）在
playground demo 里传 `style={{ width: 80, height: 80 }}`（仿照 React/Semi 常见写法，
数字默认按 px 处理），真机渲染后对应区块完全空白——不是颜色淡看不见，是元素宽高确实
为 0，DOM 节点存在但不占据任何可见空间。控制台无任何报错或警告。

**根因**：Ripple 的 `style` 对象 prop 是把 key-value **原样拼接**成 CSS `style` 属性
字符串（`width:80`），不像 React 的 `style` 处理会对数字类型的部分 CSS 属性自动追加
`px` 单位。`width:80`（无单位）是非法 CSS 值，浏览器按规范直接丢弃这条声明，效果等同
于没写过 `width`，元素退回其自身默认宽度（对于没有任何默认宽高来源的空 `<div>` 就是
0）。这一失效路径完全静默：没有 tsrx 编译期报错、没有浏览器控制台警告，只有视觉上的
"消失"，排查成本很高。

**排查弯路**：最初怀疑是自闭合空 `<div class={classes} style={style} />` 这种写法本身
有问题（对比过 Divider 组件同样的自闭合模式，工作正常，排除）；又怀疑是把 JSX 元素
通过 prop（而非 children）传递时 Ripple 编译器处理有异常（对比 Popover 的 `content`
prop 同样接收任意 JSX 且工作正常，排除）；最终用最小复现（纯 `<div style={{width:48,
height:48,background:'red'}}/>`）排除了 Skeleton 业务逻辑，逐个字段替换才定位到数字
宽高这个字段。

**修复**：`style` 对象里任何长度类 CSS 属性（`width`/`height`/`margin*`/`padding*`
等）一律传带单位的字符串（`'80px'`），不要传纯数字。已修正 playground demo 里全部
纯数字宽高写法；项目里其余组件此前的 demo 代码经抽查均已使用带单位字符串，未发现同类
问题，Skeleton 是首个踩这个坑的组件（大概率是因为它的 `style` 是纯透传、没有经过任何
内部字段拼接/默认值兜底，最直接暴露了这个差异）。

## 踩坑 #15：组件的公共视觉样式只写在"容器组件"的 `<style>` 里，若其"子组件"允许被
裸用（不经过该容器渲染），子组件单独渲染时公共样式完全不生效（2026-08-13 Skeleton
组件实测）

**现象**：Skeleton 组件族的公共底色样式（`.lotus-skeleton-element { background:
var(--lotus-color-fill-1); }`）最初只写在 `Skeleton` 容器组件的 `<style>` 块里。Semi
官方 API 里 `Skeleton.Avatar`/`Skeleton.Title` 等子组件既可以作为 `Skeleton` 的
`placeholder` prop 值使用，也可以完全脱离 `Skeleton` 独立渲染（纯展示用途）。当
demo 直接裸用 `<SkeletonAvatar />`（不包在 `<Skeleton>` 里）时，`Skeleton` 组件本身
从未被渲染过，它的 `<style>` 块自然也从未被注入到页面，导致裸用场景下所有骨架元素
都没有背景色，肉眼完全不可见（这一现象与踩坑 #11 的"`<style>` 完全不生效"表面相似，
但根因不同：#11 是语句容器写法错误导致该组件自己的 `<style>` 编译期就没被提取；这里
是每个组件的 `<style>` 各自独立注入正常，只是**该样式恰好定义在了另一个不一定会被
渲染的组件里**）。

**修复**：不要假设"公共样式所在的组件一定会被渲染"。把 `.lotus-skeleton-element`
的底色 + `active` 动效规则复制进每一个可能被独立渲染的子组件（`SkeletonAvatar`/
`SkeletonImage`/`SkeletonTitle`/`SkeletonButton`/`SkeletonParagraph`）各自的
`<style>` 块——CSS 选择器在全局作用域生效，重复定义相同规则没有副作用，只要触发
渲染的组件（无论是容器还是任意一个子组件）出现过一次，规则就存在。这个模式此后应
作为约定：一组组件里存在"可被裸用的子组件 + 可选的容器组件"关系时（Skeleton 系列、
未来可能出现的其他 xxx.SubComponent 模式），子组件共享的基础视觉样式不能只放在容器
的 `<style>` 里，必须让每个独立入口都能各自触发注入。

## 踩坑 #16：组件函数体是普通 `return <>...</>;`（而非 `@{}` 语句容器）时，`@for` 的
`key`/`index` 修饰符对应的 TrackedValue unwrap 会被 tsrx 编译器跳过，循环体内变量读到
undefined（2026-08-13 Nav 组件递归渲染实测）

**现象**：写了一个递归组件 `NavItemTree`（接收 `items` 数组 prop，内部 `@for (const item
of items; key item.itemKey) {...}` 遍历渲染），函数体用的是踩坑 #11 修复前那种"看起来更
简洁"的普通写法 `function NavItemTree(props) { return <>...</>; }`。真机 console.log 验证：
`items.length` 正确，但循环体内 `item` 本身被打印成字符串 `"TrackedValue"`（Ripple 内部
响应式包装对象），`item.itemKey`/`item.text` 等属性访问全部读到 `undefined`，导致子组件
收到的 props 全是空值，界面渲染出一片空白 `<li>`。编译期和运行时都不报错。

**根因**（已 fork tsrx-ripple 源码单独调用 `compile()` 复现验证）：`@for` 写了 `key` 或
`index` 子句时，运行时无条件把当前项包成 `TrackedValue`，编译器需要在循环体内把每次读
`item` 的地方重写成 `_$_.get(pattern)` 才能正确解包——但这个重写逻辑只在 analyze 阶段
判定"当前处于组件内"（`is_inside_component`，检查依据是函数体是否为 `JSXCodeBlock`，
即 `@{}` 语句容器）时才会生效。函数体是普通 `{ return <JSX>; }` 时这个判定漏判，`key`/
`index` 的 unwrap 重写被整体跳过；但 transform 阶段对"是否为组件"的判定更宽松（只要
`return` 了 JSX 就会包一层合成渲染函数并打上组件标记），所以模板本身照常编译出、能跑，
只是访问的是未解包的包装对象。两阶段判定时机不一致是 Ripple 编译器的真实 bug，已定位到
`analyze/index.js` 的 `JSXForExpression` 处理器与 `is_tsrx_component_function` 的判定
逻辑。

**修复**：任何用到 `@for (...; key ...)` 或 `@for (...; index ...)` 的函数（哪怕只是文件
内部非导出的辅助组件），一律用 `@{}` 语句容器写法，不要用普通 `{ return <>...</>; }`。
无 key/无 index 的 `@for (const item of items)` 不受影响。

## 踩坑 #17：`@{}` 语句容器的顶层内容如果不显式包一层 `<>...</>` fragment，函数体确实会
执行（console.log 可见），但渲染结果不会挂载到实际 DOM 树上，彻底静默失败
（2026-08-13 Nav 组件实测）

**现象**：修复踩坑 #16 后，把 `NavItemTree` 的函数体从普通 `return` 换成 `@{}`，但顶层
直接写 `@for (...) {...}`（不包 fragment）。console.log 确认 `@for` 循环体正常执行、
`item.itemKey`/`item.text` 都读到了正确的值，但页面上一个 DOM 节点都没有渲染出来——
连最简单的 `<li>ITEM: {item.text}</li>` 都不出现，且无编译期/运行时报错。

**修复**：`@{}` 语句容器的顶层可渲染内容必须显式包一层 `<>...</>`：

```tsx
// 错误：@for 直接在语句容器顶层
function NavItemTree({ items }) @{
    @for (const item of items; key item.itemKey) { <li>{item.text}</li> }
}

// 正确：包一层 fragment
function NavItemTree({ items }) @{
    <>
        @for (const item of items; key item.itemKey) { <li>{item.text}</li> }
    </>
}
```

项目里此前所有 `@{}` 组件（Divider/Avatar/Skeleton 等）碰巧都是这么写的，只是因为没人
在语句容器顶层直接放过 `@for`，才没有暴露这个坑。

## 踩坑 #18：Context 消费方的派生 track 表达式内部用 `untrack()` 包裹对 `Context.get()`
返回值的读取，会切断对该 Context 值变化的响应式依赖，子树永远拿着 mount 时刻的旧值
（2026-08-13 Nav 组件 SubNav 嵌套 Context 实测）

**现象**：`SubNav` 组件需要往自己的子树重新 `set` 一份 `{ ...父级 Context 值, isInSubNav:
true }` 的新 Context 值（对齐 Semi `NavContext.Provider` 的设计意图）。仿照 Grid
`RowContext` 的范式写派生 track，但把父级 Context 的读取包了一层 `untrack()`：

```tsx
// 错误：untrack 切断了对父级 Context 变化的响应式依赖
let &[, childContextTracked] = track<NavContextValue>(() => ({
    ...(untrack(() => contextTracked)?.value as NavContextValue),
    isInSubNav: true,
}));
```

父级 Context 后续变化（如 `selectedKeys` 更新）不会传播到子树。

**修复**：派生 track 表达式内部直接读 `contextTracked?.value`，不要包 `untrack()`：

```tsx
let &[, childContextTracked] = track<NavContextValue>(() => ({
    ...(contextTracked?.value as NavContextValue),
    isInSubNav: true,
}));
```

`untrack()` 只应该用在事件处理函数等"一次性读取当前值"的场景（如 `onClick` 里读
`ctx?.value.onItemClick(...)`），不能用在需要持续响应式更新的派生 track 表达式内部。

## 踩坑 #19：喂给 JSX 属性（`class=`/`style=`/条件分支）的派生值用普通 `const` 而非
`track()` 声明时，即使计算过程读取了 tracked 值，这个属性也只在挂载时求值一次、之后永远
不再更新，且编译期和运行时都不报错（2026-08-13 Nav 组件选中态不更新实测，排查耗时最长
的一个坑）

**现象**：点击 NavItem 后，Foundation 状态机确认更新（`console.log` 验证 `setState`
执行、`selectedKeys` 变量本身的派生 track 也重新求值），Context 也正确传播新值到子组件
（`NavItem` 内部读 `contextTracked?.value.selectedKeys` 派生 track 同样重新求值），但
`<li class={classes}>` 的实际 DOM class 属性纹丝不动——原先选中的项持续高亮，新点击的
项永远不会获得高亮 class。

**排查弯路**：一路怀疑到 Context 传播链路（怀疑跨组件嵌套、`@for`/`@if` 中间层影响
Context get/set 时机），逐层加 `console.log` 确认 `state` → `selectedKeys` →
`contextTracked.value.selectedKeys` → `NavItem` 内部 `selectedKeys` → `selected` 这条
链路上每一环都确实重新求值了，唯独最终产出的 `classes` 字符串虽然值是对的，DOM 却没有
反映出来。

**根因**：`classes` 是这样声明的：

```tsx
const classes = [
    'lotus-nav-item',
    selected ? 'lotus-nav-item-selected' : '',
    ...
].filter(Boolean).join(' ');
```

`selected` 本身是 `track()` 派生值，但 `classes` 是**普通 `const`**——tsrx 编译器判定
"某个 JSX 属性表达式是否需要生成响应式更新（对应运行时的 `_$_.set_class` 之类的 effect）"
是纯语法层面的：只看 `class={classes}` 这个属性表达式本身有没有直接引用 `track()`
解构绑定或包含函数调用，不做跨语句的数据流分析——它看不出 `classes` 这个标识符在"上一行"
的计算过程中读取过 tracked 值。因此 `class={classes}` 被编译成一次性的属性设置（只在
挂载时执行一次），`selected` 之后无论怎么变，都不会触发这个属性重新求值。

**修复**：任何最终会喂给响应式 JSX 属性、但计算过程中读取了任何 tracked/lazy 值的派生
计算，一律显式声明为 `track()`，不能用裸 `const` 先算出来再引用：

```tsx
let &[classes] = track(() =>
    [
        'lotus-nav-item',
        selected ? 'lotus-nav-item-selected' : '',
        ...
    ].filter(Boolean).join(' ')
);
```

Grid 的 `Col.classes` 早年就因为同样的原因被写成了 `track()`（本文档踩坑记录里能找到
"早期用普通 const 一次性计算…不会再重新计算"的说明），但 `Row.classes` 当时漏改、依然是
裸 `const`——只是因为 `Row.classes` 依赖的 `align`/`justify`/`className` 在现有 demo 里
从不运行时变化，没有暴露出来，本质上是同一个坑，后续如果 `Row` 的这些 props 需要做成
响应式的，需要一并修正。**这是一条通用规则，不是 Nav 专属**：任何组件里，只要一个 `const`
声明的值参与了后续某个 JSX 属性/条件渲染，且计算过程中读取了 tracked 值，都要复查是否
需要改成显式 `track()`。

## 踩坑 #20：非 `@{}` 语句容器（普通 `return <JSX>;`）的组件函数，其内部嵌套的 `@if`
条件判断在 SSR（服务端渲染）下会被完全绕过、无视条件直接执行分支内容，即使条件表达式是
`typeof x === 'function'` 这种显式类型判断；客户端渲染（CSR）完全正常，只有 SSR 受影响
（2026-08-13 Nav 文档站 demo 实测，docs 站白屏排查耗时第二长的坑，仅次于踩坑 #19）

**现象**：`NavFooter` 内部有个非导出的辅助组件 `DefaultCollapseButton`，用普通
`function DefaultCollapseButton(props) { return <button>...</button>; }` 写法（未用
`@{}`），内部有一段 `@if (typeof collapseText === 'function') { <span>{collapseText(
isCollapsed)}</span> }`——`collapseText` 是可选 prop，所有 demo 都没有传它，值应为
`undefined`，`typeof undefined === 'function'` 显然是 `false`，`@if` 分支不应该执行。
playground（纯客户端渲染）里这个组件反复真机验证完全正常。但把同样的 `<Nav
footer={{ collapseButton: true }}>` 用法接入 docs 站（用了 SSR 路由）后，访问页面
直接白屏，dev server 终端报错 `TypeError: collapseText is not a function`——`@if`
判断被完全绕过，`collapseText(isCollapsed)` 在 `collapseText` 为 `undefined` 时被
直接调用。

**排查弯路**：一路怀疑是 vite/SSR 缓存问题——`kill -9` 强制杀掉残留进程、删除
`node_modules/.vite`、多次彻底重启 dev server，报错纹丝不动，说明不是缓存问题；又
怀疑是 `@if` 条件表达式写法本身有问题（从 `@if (collapseText)` 改成更严格的
`@if (typeof collapseText === 'function')`），同样无效。

**根因**：与踩坑 #16（`@for` 的 `key`/`index` unwrap 在非 `@{}` 组件函数体内失效）
同源——tsrx 编译器判定"是否为组件函数"（`is_tsrx_component_function`）只认 `@{}`
语句容器写法的函数体，普通 `return <JSX>;` 的函数不会被标记为组件。client 端编译器
对这类"非组件但含 JSX 的纯函数"有专门的补偿通道（强制注入 `jsx_to_tsrx_element`
状态），使其在客户端渲染时表现正常；但 server 端编译器没有对等的补偿逻辑，导致这类
函数体内部嵌套的模板控制流（`@if`/`@for` 等）在 SSR codegen 路径上失去了正确的条件
判断能力——不是"预先求值"，而是编译产物本身就绕过了守卫直接执行分支内容。这是一个
真实的 Ripple 编译器 bug（client/server 两条 codegen 路径对"非 `@{}` 组件函数"的
处理不对称），不是使用姿势问题。

**修复**：项目内所有非导出的辅助/展示型子组件，只要函数体内用到任何 `@if`/`@for`
等模板控制流语法，一律必须用 `@{}` 语句容器写法，不能用普通 `return <JSX>;`——哪怕
只是文件内部的一个纯展示型小工具函数。已修复 `footer.tsrx` 的 `DefaultCollapseButton`
和 `sub.tsrx` 的 `SubNavTitleContent`。全项目已排查一遍所有非导出组件函数，确认只有
这两处受影响（其余非导出组件要么不含 `@if`，要么本来就是 `@{}` 写法）。

**关联发现**：同一次排查还发现 `apps/docs/src/demos/navigation/navigation/
controlled.tsrx` 的顶层 demo 组件 `ControlledNavDemo` 也是普通 `return <JSX>;`
写法，内部用了 `let &[x] = track(...)` 响应式状态——虽然这个函数本身不含 `@if`/`@for`，
但同样因为"未被识别为组件"，导致内部 `track()` 状态更新后压根不会触发任何重新渲染
（这是比 #16/#20 更基础的失效模式：不是某个属性/分支不更新，是整个组件都没有被当作
响应式组件对待）。**结论性规则**：任何用到 `track()`、`@if`、`@for`、Context
get/set 的函数——不论是页面级导出组件、Adapter 组件、还是文件内部的非导出辅助组件——
一律用 `@{}` 语句容器写法，普通 `return <JSX>;` 只应该用于纯静态、无状态、不含任何
模板控制流的最简单展示组件（如返回固定 SVG 图标的函数）。

## 踩坑 #21：`@if (X) { <span>A</span> @if (Y) { <span>B</span> } }` ——`@if` 分支内
部紧跟第二个渲染节点（哪怕是嵌套的 `@if`）会被 `tsrx-tsc` 拒绝：

**现象**：Typography 组件（Text/Paragraph 的 ellipsis 截断分支）编译报错
`A code block renders a single node; wrap multiple nodes or text in a fragment
'<>…</>'.`，但报错只给文件名不给行号，定位耗时较长。

**根因**：`@{}` 语句容器本身、以及 `@if`/`@for`/`@switch`/`@try` 的 `{ }` 内部，都是
tsrx 语法里的"code block"，语法规则（`@tsrx/core` 的 `#parseCodeBlockBody`）规定一个
code block 最多只能有一条"渲染语句"（一个 JSX 元素/Fragment，或一个 `@if`/`@for` 等
控制流指令），第二条渲染语句会被判定为非法，必须用 `<>…</>` 包成一个节点。这条规则
**不适用于 JSX 标签的 children 位置**（`<span>{a}{b}<C/></span>` 这种平级多子节点完全
合法，因为那是 JSX 子节点列表，不是 code block），只适用于 `@{}`/`@if{}` 花括号内部
直接并列多条渲染语句的情况——这个界限单看代码缩进容易搞混，Avatar/Breadcrumb 等已有
组件因为没有出现"`@if` 分支内部紧跟一个独立的嵌套 `@if`"这种结构，从未撞到过这条规则。

**修复**：`@if (X) { <span>A</span> @if (Y) { <span>B</span> } }` 改写为
`@if (X) { <>  <span>A</span>  @if (Y) { <span>B</span> }  </> }`，用 `<>…</>` 把
"主渲染节点 + 紧随其后的条件性附加节点"包成一个 Fragment，使整个 `@if(X)` 分支只有
一条渲染语句。

**排查方法**：`tsrx-tsc` 报错不含行号时，用最小复现法二分排查——建立一个临时 `.tsrx`
文件，从疑似组件里逐段搬运代码直到复现报错，再逐段删减到最小片段。本次定位到根因后
临时文件已删除，不要把排查过程中的临时文件误提交。

## 踩坑 #22：`children` 在 JSX 标签子节点写法下永远是编译期包装的 `TSRXElement`
对象，组件逻辑代码无法读取其字符串内容；改用 `children={'...'}` 显式 prop 写法才会
原样透传原始值：

**现象**：Typography 组件的 `ellipsis`（截断计算需要读取文本长度）、`copyable`
（默认复制 `children` 内容）用 `typeof children === 'string'` 判断文本类型，写
`<TypographyText ellipsis={{...}}>这是一段文字</TypographyText>` 时该判断恒为
`false`，截断/复制功能全部静默失效，没有任何报错提示。

**根因**：用浏览器真机探针实测（`console.log(typeof children)`）+ 阅读
`~/i/ripple/packages/tsrx-ripple/src/transform/client/index.js` 编译器源码确认：
`<Component>纯文本</Component>` 这种 JSX 标签夹子节点的写法，编译器在
`element_children.length > 0` 时**无条件**走 `_$_.tsrx_element(...)` 包装路径
（`create_native_tsrx_render_function` + `tsrx_element` 调用），不管子节点内容是
纯字符串还是别的，运行时 `children` 永远是 `{ render: Function, [TSRX_ELEMENT]: true }`
形状的对象，不是原始字符串。但 `<Component children="纯文本" />`（作为**显式 prop**
传入）走的是另一条编译路径（`attr_name === 'children'` 分支），调用
`_$_.normalize_children(property)`，其实现（`packages/ripple/src/runtime/element.js`）
对非函数值原样透传，此时 `typeof children === 'string'` 为 `true`。这不是 lotus
的实现 bug，是 Ripple 编译器两条 children 生成路径的既有差异（GitHub issue #1043
的评论区也印证了 `<Foo children={...} />` 是官方认可的标准写法）。

**修复**：任何依赖读取 `children` 原始字符串内容的组件 API（ellipsis 截断计算、
copyable 默认复制内容），必须在文档和示例里注明调用方要用
`children={'...'}` 显式 prop 写法，不能用 `<Text>...</Text>` 标签子节点写法。
`isPlainText = typeof children === 'string'` 这个判断本身没有问题，问题在于
只有正确的调用姿势才能让它命中 `true`。

**排查方法**：怀疑 `children` 类型判断失效时，先用最小探针组件
`console.log(typeof children, children)` 在两种调用写法下分别测试，不要凭直觉
断言"Ripple 不支持读取 children"——这次先验证了"标签子节点写法"失效，又验证了
"显式 prop 写法"成功，才定位到差异点在语法层面而非能力层面。

## 踩坑 #23：跨文件复用同一批 `.lotus-xxx` class 名时，只在其中一个文件的
`<style>` 块里定义公共样式，另一个文件单独使用时样式完全缺失：

**现象**：Typography 的 `Title`/`Paragraph` 组件单独渲染时（不和 `Text` 同时出现
在页面上），完全没有 `font-family`/`color`/`font-size`/`line-height` 等基础样式，
计算出的 `line-height` 是浏览器默认值 `"normal"`（无法转成像素数），导致依赖
`line-height` 做精确高度计算的 JS 截断算法（`measureEllipsisText`）从一开始就
判定"任何长度都超出可用高度"，返回最小兜底值。

**根因**：tsrx 组件的 `<style>` 块是**全局注入**（编译后作为普通 `<style>` 标签
插入文档，不是 CSS Modules 那种按文件强隔离的 scope），此前 `sub.tsrx` 复用
`item.tsrx` 定义的 `.lotus-nav-item-icon` 等 class 之所以能生效，是因为 Nav 场景
下 `item.tsrx` 总是先于/同时被引用触发样式注入。但这只是"运气好、恰好一起用"，
不是可依赖的保证——一旦某个消费方（如只用 `TypographyTitle` 不用 `TypographyText`
的页面）没有一并触发另一个文件的注入，共享的基础样式就会整体缺失。

**修复**：`Title`/`Text`/`Paragraph` 三个组件文件各自在自己的 `<style>` 块内
完整复制一份基础共享样式（`.lotus-typography` 主体 + 各 `type` 颜色变体 +
`mark`/`delete`/`underline`/`link`/`icon`/`copy` 等），不依赖"运气好、另一个文件
恰好也被引用"这个隐式前提。**结论性规则**：任何跨文件复用的 class 名，若无法
保证消费方一定会同时引用定义它的文件，就必须让每个消费方各自持有完整定义
（哪怕产生样式代码重复），不要假设 tsrx 的全局样式注入顺序。

## 踩坑 #24：`<Tooltip>` 包裹一个需要撑满外层容器宽度做 `text-overflow:ellipsis`
截断的元素时，`lotus-tooltip-trigger` 默认 `display:inline-block`（shrink-to-fit）
会打断宽度传导链，导致内层元素撑到内容的完整宽度而非父级容器宽度，`text-overflow`
永久不触发；对齐 Semi `Tooltip.wrapSpan` 的 `block`/`blockDisplays` 检测逻辑修复：

**现象**：`<div style={{width:'160px'}}><Tooltip content={fullText}><span
class="...ellipsis-line">超长文本</span></Tooltip></div>` 里，内层 `<span>`
即使自身有 `overflow:hidden; text-overflow:ellipsis; width:100%`，实测宽度
（`getComputedStyle(el).width`）却是文本内容的完整宽度（如 420px），远超外层 160px
容器，视觉上完全没有省略号，文字被硬截断在容器边缘且看不出裁切逻辑。

**根因**：`lotus-tooltip-trigger`（Tooltip 组件内部渲染的触发元素包裹层）硬编码
`display:inline-block`，`inline-block` 元素默认宽度是"收缩到内容"（shrink-to-fit），
不会主动撑满父容器。子元素 `width:100%` 相对的是这个"跟着内容一起收缩/撑大"的
父级，两者形成闭环——最终浏览器选择让整条链路都跟随最长内容撑开，而不是被外层
`160px` 约束。这与 React 版 Semi Tooltip 遇到的问题完全一致，Semi 的解法记录在
`packages/semi-ui/tooltip/index.tsx` 的 `wrapSpan` 方法：**检测 children 元素的
`props.style.display`（是否属于 `['flex','block','table','flow-root','grid']`）
或 `props.block`，命中则给 trigger wrapper 也加上 `width:100%`**，让宽度约束从
最外层容器一路传导到底。

**修复**：Ripple 的 `children` 是编译期包装的渲染句柄（见踩坑 #22），组件逻辑
代码无法像 React 那样反射读取子元素的 `props.style.display`/`props.block`，
只能改为**显式声明**代替**自动推断**（与 Avatar 的 `isText` prop 同一处理模式）：
给 `Tooltip` 新增 `block?: boolean` prop，调用方在包裹块级/需要撑满宽度的内容时
显式传 `<Tooltip block content={...}>`，trigger wrapper 据此把
`display:inline-block` 覆盖为内联 `style={{width:'100%'}}`（默认
`block=false`，不影响任何已验证的现有 Tooltip 用法）。`TypographyText`/
`TypographyParagraph` 的 `showTooltip` 场景已按此方式接入。

**关联发现**：Semi 的 `showTooltip` 单独存在（无 `pos='middle'`/`expandable`/
`suffix`/`copyable`）时走的是**纯 CSS 截断**，Tooltip 包裹的是"已经渲染好、带
`ellipsis` class 的最终内容整体"（`renderTipWrapper` 里 `<Tooltip
content={children}>{content}</Tooltip>`，`content` 即 `renderContent()` 的完整
产出），不是把 Tooltip 包在内层文字节点上再嵌一层。本次实现最初把 `<Tooltip>`
包在 `<span class={classes}>` **内部**（包着测量后的文字），导致 class 上的
`ellipsis-line`/`text-overflow` 样式和 Tooltip 触发元素分处两层，即使解决了宽度
传导也会有"样式定义层"和"Tooltip 触发层"割裂的问题；改为 `@if (showTooltip) {
<Tooltip block content={children}><span class={classes}>...</span></Tooltip> }
@else { <span class={classes}>...</span> }`——把整个"已经决定好 class/style 的
容器"作为 Tooltip 的直接 children，才是与 Semi 结构对齐的正确写法。

## 踩坑 #25：喂给非文本类 JSX 属性（`style`）的合并对象同样必须显式 `track()`，
不能用普通 `const` 一次性计算——这是踩坑 #7/#19 的又一次独立复现，这次命中的是
`style` 属性而非 `class`：

**现象**：TextArea 组件的 `autosize` 功能——挂载后在 `effect()` 里测量内容高度、
写入 `autoHeight` 状态，再拼进 `mergedTextareaStyle` 对象传给 `<textarea style=...>`
——高度测量本身工作正常（`autoHeight` 状态确实在变化），但 DOM 上的 `<textarea>`
元素永远没有 `style` 属性（`getAttribute('style')` 恒为 `null`），高度视觉上完全
不随内容变化。

**根因**：`mergedTextareaStyle` 写成了普通 `const mergedTextareaStyle = { ...
(autoHeight ? {...} : {}), ...textareaStyle };`。这是踩坑 #7/#19 那条规则
（"喂给 JSX 属性的派生值必须显式 `track(() => ...)`，普通 `const` 一次性计算不会
在依赖的 track 值变化时重新求值并触发渲染更新"）在 `style` 属性上的又一次独立
命中——此前两次记录的案例都是 `class` 拼接，这次证明该规则同样适用于任何 JSX
属性表达式，不只是 class。排查方法：怀疑响应式属性不生效时，先用
`element.getAttribute(name)`（而非 `element.value` 等 DOM property）确认属性
是否真的被写入过，`null`/空值说明属性绑定这层表达式本身没有被判定为响应式依赖，
而不是"写入了但计算结果不对"。

**修复**：`let &[mergedTextareaStyle] = track<Record<string, any>>(() => ({ ... }));`，
与所有喂给 JSX 属性的派生值一致处理。

## 踩坑 #26：容器内某个子元素的显隐依赖 hover 状态时，`onMouseEnter`/
`onMouseLeave` 必须绑定在"实际视觉边界与显隐判定意图一致"的容器节点上，而不是
绑在触发交互最频繁的子元素（如原生表单控件）上——绑错节点会导致鼠标移向新出现的
兄弟元素时意外触发 `mouseleave`，元素刚显示又立刻消失：

**现象**：TextArea 的清除按钮（`showClear`，hover 时显示）用 Playwright 做真实
鼠标点击验证时反复报 `element was detached from the DOM, retrying` /
`<html> intercepts pointer events`，超时失败；但用 `element.click()` 直接调用
（不模拟真实鼠标移动路径）却完全正常——这个差异本身就是排查线索：说明问题出在
"鼠标真实移动到目标位置的过程中"，不是点击处理逻辑本身。

**根因**：`handleMouseEnter`/`handleMouseLeave` 错误地绑在了 `<textarea>` 元素
本身上，而清除按钮渲染在 `.lotus-textarea-footer`（`<textarea>` 的兄弟节点，在
外层 `.lotus-textarea-wrapper` 容器内、但在 `<textarea>` 元素之外）。当鼠标从
`<textarea>` 内部移动到清除按钮时，会先离开 `<textarea>` 的边界触发它的
`mouseleave`，导致 `isHovering` 变回 `false` → `allowClear` 重新计算为 `false`
→ 按钮从 DOM 移除——鼠标还没真正到达按钮就已经把按钮撤走了，构成"按钮永远够不
着"的死锁。对照组：`Input` 组件把 `onMouseEnter`/`onMouseLeave` 正确绑在了
`.lotus-input-wrapper`（外层容器，清除按钮在其内部），从未出现这个问题。

**修复**：`onMouseEnter`/`onMouseLeave` 统一绑定在包裹"输入控件 + 所有可能因
hover 而显隐的兄弟元素（清除按钮、字数统计等）"的最外层容器节点上，不要图省事
绑在最内层的原生表单控件（`<input>`/`<textarea>`）上——即使当前视觉上二者的
悬浮区域看起来一样大。**结论性规则**：任何"hover 出现的兄弟元素"场景，必须先
画出真实的 DOM 树形结构，确认 hover 监听节点的边界完全包含所有需要因它而显隐
的元素，不能想当然认为"绑在被 hover 的那个元素上就够了"。

## 踩坑 #27：图标生成脚本对"单色线框图标包"有效的 `currentColor` 颜色替换
策略，套用到"故意多色/带 mask 镂空效果的图标包"上会静默破坏图标设计：

**现象**：`@lotus/icons-lab`（对应 Semi 官方 `semi-icons-lab`，定位是应用/组件
风格的多彩徽标图标）回填进 Nav demo 后，真机截图发现 `IconAvatar` 渲染成一个
纯黑实心圆点，完全看不出人像剪影细节；放大截图确认不是视觉误判，是真实的颜色
塌缩。

**根因**：`packages/icons-lab/scripts/generate-icons.ts` 的 svgo 插件直接复制
了 `@lotus/icons`（主包，单色线框图标）的 `convertColors` 配置——
`{ currentColor: /^(?!url|none)./ }`，无差别把所有非 `url()`/`none` 的颜色值
替换成 `currentColor`。但 `IconAvatar` 源文件 `avatar.svg` 是"橙黄色背景圆
（`#FBCD2C`）+ 白色人像剪影（`fill="#fff"`）+ `<mask>` 镂空"的多色设计，替换后
背景圆和人像 path 变成同一个 `currentColor`，人像细节在视觉上被背景完全吞没。
排查发现 `packages/icons-lab/svgs/` 下 84 个源文件里有 78 个都是这种多色设计
（`grid.svg`/`banner.svg`/`steps.svg` 等），不是 `IconAvatar` 一个特例，是系统性
问题——`@lotus/icons` 主包和 `@lotus/icons-lab` 附加包虽然生成脚本结构几乎相同，
但对应的 Semi 源图标在颜色语义上完全不同（一个是单色描边给 `currentColor`
继承用的，一个是固定多彩配色的成品徽标），不能共用同一份 svgo 颜色处理插件配置。

**修复**：`packages/icons-lab/scripts/generate-icons.ts` 的 `svgoPlugins` 去掉
`convertColors` 插件，只保留 `preset-default`/`removeDimensions`/`removeXMLNS`，
完整保留源 SVG 的原始 fill 值；同步删掉 `extractInner` 里针对"未被替换的黑色
fill"的防御性警告（该警告的前提假设——所有图标都应该被替换成 currentColor——
在 icons-lab 语境下本身就不成立）。修复后重新跑 `pnpm generate` 全量重新生成
84 个组件，`IconAvatar` 恢复橙黄底+白色人像的正确视觉效果。

**结论性规则**：多图标包/多来源图标的生成流水线，颜色处理策略必须按"图标包的
设计语义"分别配置，不能假设"这个 svgo 插件在包 A 上验证过没问题，直接复用到
包 B 上"。区分方法：搭建新图标包前，先抽查源 SVG 文件里有几种不同的 `fill`
颜色值——只有一种（或只有黑/`#000`）大概率是单色线框图标，可以放心用
`currentColor` 继承色策略；出现三种以上不同色值（尤其是非黑非白的具体颜色）
基本可以判定是故意设计的多彩图标，必须完整保留原始颜色，不能替换。

**补充（同一坑的第二现场）**：全量走查阶段发现 `@lotus/icons`（主包，523 个
Semi 正式图标）同样踩了这个坑，只是范围小得多——`packages/icons/svgs/` 下
`ai_*_level_2.svg`（8 个，黑色主体 + 紫色 `#A647FF` 强调色）和 `ai_*_level_3.svg`
（8 个，`<linearGradient>` 四档渐变 `#E945FF → #A647FF → #6B61FF → #2E8CFF`）
共 16 个 AI 功能等级品牌图标，也是故意多彩/渐变设计，被主包脚本的
`convertColors` 统一替换成了单色。与 icons-lab"全量禁用"的修法不同，这里因为
主包 523 个图标里只有这 16 个是例外（`*_level_1.svg` 同名系列反而是纯黑单色，
应该正常走 `currentColor`），改成了白名单机制：`packages/icons/scripts/
generate-icons.ts` 新增 `MULTI_COLOR_ASSETS` 常量登记这 16 个文件名，生成循环
按文件名判断走 `commonSvgoPlugins`（不含 `convertColors`）还是完整的
`svgoPlugins`。**结论性规则的推论**：即使同一个图标包整体上是"单色线框"语义，
也不能想当然假设它是纯粹的——批量生成前先跑一次「抽查源 SVG 颜色数量」的检查
脚本或人工采样，尤其留意品牌/渐变/等级类命名的文件（`*_level_N`、`*_gradient`、
`*_colorful` 等命名模式往往就是多彩设计的信号）。

**补充二（扫描方法本身的盲区）**：按上面"抽查源 SVG 颜色数量"的方法对
`packages/icons/svgs/` 全量重扫时，一开始只用正则匹配 `fill="..."` 属性统计
颜色种类，`ai_loading.svg` 因为渐变是通过 `stroke="url(#gradient)"` 引用
（而不是 `fill="url(...)"`），没有任何独立的 `fill` 颜色声明，被误判为"其他
类别"漏检，实际上它和 `ai_*_level_3` 系列是同一套 AI 品牌渐变色
（`#E945FF → #A647FF → #6B61FF → #2E8CFF`），生成后渐变塌缩成了纯色。
**结论性规则的再推论**：扫描 SVG 源文件的颜色/渐变引用时，`fill` 和 `stroke`
两个属性都必须检查——`<path>` 既可能用 `fill="url(#x)"` 也可能用
`stroke="url(#x)"` 引用同一个 `<linearGradient>`/`<radialGradient>`
定义，只查其中一个会有遗漏。已修复：`ai_loading.svg` 追加进
`MULTI_COLOR_ASSETS` 白名单，重新生成后渐变恢复正常。

## 踩坑 #28：`.tsrx` 文件里的 `eslint-disable-next-line` 行内指令注释完全不生效

**现象**：CI 跑 `pnpm lint` 暴露 12 处 `ripple/prefer-oninput` warning——都是
`Input`/`TextArea`/`Switch`/`Tabs` 组件自己定义的公开 `onChange` prop（对齐
Semi Design 官方同名 prop 语义），不是原生 DOM 元素上误写的合成事件，属于这条
规则的误判场景（规则实现纯字符串匹配 `JSXAttribute[name.name="onChange"]`，
不区分挂在原生元素还是自定义组件上）。给触发行加了标准写法的
`// eslint-disable-next-line ripple/prefer-oninput -- ...`（或 JSX 场景下的
`{/* eslint-disable-next-line ... */}`），重新跑 `pnpm lint`，警告数量一个没
变——注释形式在标准 `.ts`/`.tsx` 文件里完全正确，但在 `.tsrx` 文件里没有任何
效果。

**根因**：用 Node 直接调用 `@tsrx/eslint-parser`（版本 `0.3.119`）的
`parseForESLint(code, options)` API 对受影响文件做最小复现，`result.ast.
comments` 返回的是空数组——parser 完全没有把源码里的注释提取出来交给
ESLint。ESLint 处理行内指令注释（`eslint-disable(-next-line)`）依赖的正是
`ast.comments`，注释数组为空，ESLint 自然读不到任何指令，行内禁用（不管
`//` 还是 `{/* */}` 形式，也不管放在语句块级还是紧贴触发行）在 `.tsrx` 文件
里全部沉默失效，不会报错也不会生效，非常容易被误判为"注释放错位置"而反复
调整位置无效。整文件级别的 `/* eslint-disable ripple/xxx */` 同样无效，
确认问题出在注释收集这一层，与放置位置、单行/块级写法无关。

**修复**：放弃行内注释这条路径，改用 `eslint.config.js` 里按精确文件路径
数组关闭规则：
```js
{
  files: ['apps/docs/src/demos/input/input/basic.tsrx', /* ... 逐一列出核实过的文件 */],
  rules: { 'ripple/prefer-oninput': 'off' },
}
```
特意用文件路径清单而非宽泛的 glob（如 `apps/docs/src/demos/**`），因为宽泛
匹配会连带关闭这条规则对同目录下其他文件里真实 DOM `onChange` 误用的检测
能力——每个进入清单的文件都要先人工确认过"这里的 onChange 是组件 prop 不是
原生 DOM 事件"，不能因为行内注释无效就图省事直接关掉大范围规则。

**结论性规则**：在 `.tsrx` 文件里遇到"加了 eslint-disable 注释但警告没有
消失"的情况，第一反应不是怀疑注释写法或位置（这是 `.ts`/`.tsx` 里最常见的
误用原因，但在这里是错误假设），而是怀疑自定义 parser 是否正确实现了
`comments` 收集——可以用上面的最小复现方法（`node` 直接 `import` parser 包
调 `parseForESLint`，打印 `result.ast.comments.length`）快速验证，比反复
调整注释位置试错快得多。这是 `@tsrx/eslint-parser` 这个特定版本的工具局限，
不是 tsrx 语言设计的必然限制，未来该 parser 修复后可以把 `eslint.config.js`
里的按文件禁用改回行内注释，颗粒度更细。

## 踩坑 #29：图标生成脚本硬编码 SVG `<mask>`/`<clipPath>` 的局部 id，
同一图标组件多实例渲染会产生重复 id

**现象**：全量走查图标系统时注意到 `packages/icons-lab/src/IconAvatar.tsrx`
用 `<mask id="a">` 定义人像剪影的镂空效果，`id="a"` 是 svgo 处理源文件时保留
的固定字符串（Semi 官方源文件里其实是构建工具生成的随机串，如
`mask0_1_3014`，移植时被简化成了 `"a"`）。这意味着同一个页面渲染两个及以上
`<IconAvatar />` 实例时，DOM 里会出现多个 `id="a"` 的 `<mask>` 元素，违反
HTML "id 全文档唯一" 的约束；`<g mask="url(#a)">` 在有多个同 id 元素时到底
引用哪一个，不同浏览器实现的行为并不保证一致，是潜在隐患（当时评估这个
具体场景在现有 demo 里不会触发——没有任何 demo 同时渲染多个 IconAvatar
实例——所以先记录风险、没有立即修复）。后续排查发现 `packages/icons-lab/
svgs/` 下还有 7 个其他图标（`date_picker`/`form`/`navigation`/
`notification`/`rating`/`select`/`toast`）也用了同样的硬编码 id 模式定义
`<clipPath>`，是同一类问题的更大范围版本，不是 `IconAvatar` 一个特例。

**修复**：没有针对 `IconAvatar.tsrx` 单独手改（手改会在下次 `pnpm generate`
重新生成时被覆盖，且不能覆盖到另外 7 个同类文件），改在
`packages/icons-lab/scripts/generate-icons.ts` 的生成逻辑里加通用处理：
`extractLocalIds()` 用正则扫描 `innerJsx` 里所有 `id="xxx"` 声明，
`makeIdsUnique()` 把每个声明处和对应的 `url(#xxx)` 引用都替换成基于组件
内 `uid` 模板字符串变量的插值写法；`generateComponent()` 检测到某个图标
含本地 id 时，自动在函数体开头插入 `const uid = \`lotus-${componentName.
toLowerCase()}-${uidCounter++}\`;`（`uidCounter` 是模块级自增计数器，每次
调用组件函数生成一个新的唯一后缀）。不含 id 的图标（占绝大多数）生成逻辑
不变。重新跑 `pnpm generate` 后 8 个受影响文件全部正确改写，真机验证（同一
页面并排渲染 3 个 `<IconAvatar />`）确认 3 个 mask id 互不相同
（`lotus-iconavatar-0-a`/`1-a`/`2-a`），人像剪影渲染正常。

**结论性规则**：图标搬运/生成脚本对 SVG 源文件的处理，除了颜色语义（见
踩坑 #27）之外，还要检查源文件是否用了 `id` 属性定义局部引用目标
（`<mask>`/`<clipPath>`/`<linearGradient>`/`<radialGradient>` 等都常见这个
模式）——构建工具生成的原始 id 通常是随机串保证跨文件唯一，人工/脚本简化
成固定字符串后，唯一性保证被破坏，只有在同一组件多实例渲染的测试场景下
才会暴露。批量生成脚本应该把"id 唯一化"作为通用后处理步骤而非针对个别
文件手工修复，避免同一类问题在不同图标文件里重复出现却分别踩坑。

## 踩坑 #30（重大）：组件 props 用普通 `{...}` 解构会丢失响应式，
跨组件的 prop 变化无法传导给子组件——必须用 `&{...}` 懒解构

**现象**：开发 Checkbox/CheckboxGroup 时，写了一个"受控组件"（`checked`/
`value` + `onChange`，外部持有状态、通过 props 双向绑定），单独使用时点击
自己没问题，但用一个**外部按钮**去驱动这个受控值变化（`<Checkbox checked=
{x} onChange={(v) => { x = v }} />`，另一个 `<Button onClick={() => { x =
!x }}>`）时，点击外部按钮后 `x` 这个 track 变量确实变了（`console.log`
验证过），但 `Checkbox` 的视觉完全不跟着更新。CheckboxGroup 受控模式下更
严重——`<CheckboxGroup value={arr} onChange={...}>` 外部改变 `arr` 后，
内部所有 `<Checkbox>` 子项完全不重新渲染。

排查过程极其曲折（教训见下），最终用一系列独立的最小复现组件锁定：问题
与数组/对象类型无关，与 `RippleArray`/`children` prop/`untrack()` 都无关，
唯一决定性变量是**组件签名的解构写法**。

```tsrx
// ❌ 错误：普通解构，急切拷贝 props 里的值，之后这些局部变量永远不再更新，
// 即使父组件用新的 props 重新调用这个函数也没用——因为编译后的组件更新机制
// 依赖的是"局部变量本身是否被声明为对 props 字段的惰性引用"，普通解构产出的
// 是解构那一刻的值快照，不是引用。
function Checkbox({ checked, onChange, ... }: CheckboxProps) @{ ... }

// ✅ 正确：&{...} 懒解构，每个变量编译成对 props 对象的惰性属性访问
// （deferred property lookup），props 对象本身变化时这些变量会跟着更新。
function Checkbox(&{ checked, onChange, ... }: CheckboxProps) @{ ... }
```

**根因**：Ripple 官方文档（`~/i/ripple/website/docs/guide/reactivity.md`
"Lazy Destructuring" 一节）明确写着：

> Regular destructuring (`{ a, b } = obj`) eagerly copies values and loses
> reactivity... Use `&{...}` whenever you destructure reactive props or
> tracked objects and need the variables to remain reactive.

`&{...}`/`&[...]` 是 Ripple 语言层面的懒解构语法（`&` 前缀直接放在 `{`/`[`
前面），每个解构出的变量会被编译成对源对象的**延迟属性/索引查找**，而不是
一次性拷贝出的值。**这在文档里是被明确要求的组件 props 写法，但本项目从
第一个组件到 Checkbox 之前，全部组件清一色用了普通 `{...}` 解构**——之所以
此前从未暴露，是因为：
1. 大多数受控 demo 的"外部触发更新"场景，实际触发路径是"用户在这个组件
   自己的 DOM 节点上操作"（如 `Input` 的受控 demo 是 `.fill()` 直接在
   这个 `<input>` 上模拟输入），这条路径靠的是原生 DOM 事件 + 组件内部
   `state` 响应，根本不经过"外部 prop 变化→组件重新渲染"这条链路，测试
   "过了"但没测到真正的受控契约。
2. 少数真正测试"点击组件自己内部触发,再验证自己视觉"的场景（Switch 的
   e2e），也不经过跨组件 prop 传导，只要组件内部 `state` 正确即可通过。
3. **全项目没有一个 e2e 测试覆盖"外部独立按钮驱动受控 prop 变化，断言
   被动接收方组件视觉更新"这个模式**——这才是受控组件的核心契约，却是
   测试盲区。

**修复**：`Checkbox`/`CheckboxGroup` 的组件签名从 `function Xxx({ ... }:
Props) @{` 改为 `function Xxx(&{ ... }: Props) @{`，问题立即解决（用最小
复现逐个验证过：普通解构+`RippleArray`+组件内部再包一层 `track()`，都不能
单独解决；只有 `&{...}` 才能）。

**结论性规则（重大，需要审计现有组件）**：这不只是 Checkbox 一个组件的
bug，是**贯穿整个项目、影响所有现有组件的系统性风险**——只要某个组件的
props 存在"父组件在没有该组件自身触发交互的情况下，独立改变某个 prop 值，
期望子组件被动响应更新"这种用法（这正是"受控组件"这个模式的定义本身），
用普通 `{...}` 解构的组件大概率都有这个问题，只是恰好没被现有 demo/测试
覆盖到而暴露。已知使用普通解构的组件（几乎是全部）：Button、Divider、
Space、Grid、Layout、Typography（三个子组件）、Switch、Input、TextArea、
Tag、Avatar、Tooltip、Popover、Dropdown（及子组件）、Tabs、Breadcrumb、
Skeleton（及子组件）、Nav（及子组件）。**后续每开发/修改一个组件，props
解构一律使用 `&{...}`，不再使用普通 `{...}`**；对存量组件，建议后续排一次
系统性审计+回归测试（optional next step 里已经记录）。

**排查过程的教训（怎样更快定位到这个问题）**：这次排查耗费了大量轮次，
反复怀疑了 `RippleArray`、`children` prop、`untrack()`、HMR 缓存、Playwright
工具本身的坐标问题，最后才找到根因，复盘下来更快的路径应该是：
1. 一开始就应该去读 Ripple 官方文档的 Reactivity 一章，而不是纯靠试验
   猜测——`&{...}`/`RippleArray` 都在文档里有专门章节，且用加粗强调写明
   "此时必须用 XXX"。**遇到"响应式没生效"这类问题，先查官方文档的
   reactivity/props 相关章节，比开一堆最小复现组件试错快得多**。
2. 用**独立于既有大文件的最小复现**（新建组件、只有一两行逻辑）排查，
   比在 `App.tsrx`（600+ 行、混杂大量既有 demo）里加代码排查干扰更少——
   但即使用了最小复现，也要小心 HMR 增量更新可能保留旧组件实例状态
   造成假阳性，**每次修改后应该完全重启 dev server + 硬刷新（或新开一个
   干净的浏览器 tab）再验证**，不能只依赖 Vite 的 HMR。
3. 用 `console.log` 在浏览器里验证程序化调用（`element.click()`）的结果
   之前，要意识到**程序化 `.click()` 掩盖真实 UX 问题**这条已知踩坑
   （#24/#26 的教训）不仅适用于点击本身触发的行为，也可能让人误判"响应
   式生效了"——回头看，第一次误以为"成功"的那次验证，很可能是 HMR 增量
   更新期间的巧合状态，而不是真正的响应式生效，应该立刻用 Playwright 或
   完全重启后的干净环境复核，而不是继续往下走。

## 踩坑 #31：视觉隐藏的原生表单控件（`clip: rect(0,0,0,0)` 模式）无法被
Playwright／鼠标点击命中，必须让可点击容器承接交互

**现象**：Checkbox 用了标准的"视觉隐藏但保留给屏幕阅读器"CSS 模式隐藏
原生 `<input type="checkbox">`（`position: absolute; width: 1px; height:
1px; margin: -1px; overflow: hidden; clip: rect(0,0,0,0)`），可见的选中框
用旁边的 `<span class="lotus-checkbox-box">` 承担。Playwright 用
`page.getByLabel(...).click()` 点击这个 `<input>` 时，反复报
`<label>...intercepts pointer events` 和 `element is outside of the
viewport`，重试到超时失败；但浏览器里用 JS `element.click()` 程序化调用
却完全正常（这个差异是排查线索）。

**根因**：用 `document.elementFromPoint()` 直接命中测试 `<input>` 的几何
中心坐标，发现命中的不是 `<input>` 本身、也不是它的父级 `<label>`，而是
页面**最外层的根容器 `<div>`**（`childCount: 115`，无 class）——说明
`clip: rect(0,0,0,0)` 这个裁剪属性会让浏览器的 hit-testing 直接"跳过"这个
元素（即使给它加了 `pointer-events: none` 也无法解决，因为问题根本不是
"这个元素挡住了点击"，而是"这个元素本身在这个位置对点击测试不可
见"）。Playwright 的 `.click()`（模拟真实用户交互）会做这类可点击性
校验，而 JS 程序化 `element.click()` 是直接调用 DOM API 触发事件，不做
任何几何/可见性检查，因此表现不同——这正是"程序化 click 掩盖真实 UX 问题"
（踩坑 #24/#26）的又一实例：如果只用程序化点击验证过，这个问题会被完全
掩盖过去，永远不会发现真实用户/自动化工具点不到这个元素。

**修复**：e2e 测试不去点击这个视觉隐藏的 `<input>` 本身，而是定位它的
可见父容器 `<label>`（`checkbox.locator('xpath=..')`）来发起点击——这也
更贴近真实用户的操作方式（用户点的是可见的方框，不是这个不可见的
`<input>`）。组件本身保留 `<label onClick={...}>` 统一承接交互的设计
不变，`<input>` 只做状态展示 + `aria-label` 语义。

**结论性规则**：任何用"视觉隐藏但屏幕阅读器可见"模式（`clip`/`clip-path`
配合 1px 尺寸）隐藏原生表单控件的组件，e2e 测试点击操作必须作用于外层
可见容器，不能对着这个隐藏元素本身发起点击断言；这类元素上也不需要绑定
`onClick`（交互统一在外层容器处理），避免维护者以为"点击隐藏 input 就够
了"而重复踩这个坑。

## 踩坑 #32：Foundation 的 `getState()` 在受控模式下不能读取内部 state
快照——快照在受控时永远是初始化那一刻的旧值

**现象**：`CheckboxGroup` 受控模式下（`value`+`onChange` 外部持有选中值
数组），连续操作：先勾选 B（B: false→true，通过 `onChange` 正确通知外部，
外部数组变成 `['A','B']`），再点击 A（应该只影响 A，B 保持选中）——结果
点击 A 后，B 的选中状态被意外清空。

**根因**：`CheckboxGroupFoundation.toggleValue()` 需要用"当前完整的选中
集合"做增删运算（`value.includes(itemValue)` 判断是否已选中，进而决定
`filter` 还是 `[...value, itemValue]`）。这个"当前完整集合"来自 Adapter
的 `getState()`，而 `group.tsrx` 里 `getState: () => untrack(() => state)`
——**永远读内部 track 变量 `state`，但受控模式下 `state` 从未被
`setState` 更新过**（受控分支只调用 `onChange`，不调用 `this.setState`，
这是受控组件的标准设计——真实状态由外部持有）。于是 `state.value` 永远
停留在组件挂载那一刻的初始值（这里是 `['A']`，因为受控 `value` prop 首次
渲染时的初始值），点击 B 时 `onChange` 拿到的 `next` 是基于这个旧快照
算出来的、看似正确（`['A','B']`），但这个正确只是巧合（因为第一次操作，
旧快照恰好还没过时）；第二次点击 A 时，`getState()` 依然返回过时的
`{ value: ['A'] }`（完全不知道 B 已经被勾选），`toggleValue('A', ...)`
算出 `next = ['A'].filter(v => v !== 'A') = []`——把 B 也一并弄丢了，因为
Foundation 从始至终不知道 B 存在。

**修复**：`getState()` 必须区分受控/非受控，受控时返回**当前外部
prop 值**而不是内部快照：
```tsrx
const foundation = new CheckboxGroupFoundation({
    getState: () => ({ value: isControlled ? (value ?? []) : untrack(() => state.value) }),
    setState: (patch) => { state = { ...state, ...patch }; },
});
```

**结论性规则**：任何 Foundation 方法如果需要基于"当前完整状态"做增量
运算（不是简单取反或整体替换，而是要读旧值算新值，比如集合增删、数组
过滤、依赖前一个值的计算），受控模式下的 `getState()` 绝不能只读内部
`state`——内部 `state` 在受控模式下是"事实上已经失效的初始快照"，必须
显式按 `isControlled` 分支返回外部 prop 的当前值。纯粹的"取反"
（`SwitchFoundation.handleToggle` 的 `!checked`）或"整体替换"
（`InputFoundation` 直接用新 value 替换）类逻辑不受这个问题影响，因为
它们不依赖"旧值里除了这一个字段之外的其他部分"，只有像 `toggleValue`
这种"从集合里精确增删一个元素、必须保留其余元素"的逻辑才会踩这个坑。
新增类似"集合类受控状态管理"的 Foundation（比如未来 Select 多选、
Transfer 穿梭框的选中集合）时要对照检查这一点。

## 踩坑 #33：自己接管 Popover 开关状态实现"点击外部关闭"时，判断范围必须
同时包含浮层内容节点——只判断触发器容器会把"点击浮层内选项"误判为外部点击

**现象**：Select 是第一个复用 Popover/浮层定位基础设施、但不满足于"再点一次
触发器切换开关"这个默认交互的组件——选择器类组件还需要"选中单选项后自动
关闭"和"点击页面任意其他地方关闭"，所以用 `Popover trigger="custom"` 完全
自己接管开关状态，组件挂载时装一个常驻的 `document` 级 `mousedown` 监听器，
点击目标不在 Select 根节点内时就收起下拉。真机验证时发现：点击触发器展开
下拉没问题，但点击下拉列表里的选项后，浮层正确关闭了，触发器上显示的选中值
却没有变化（点了"西瓜视频"，界面还显示原来的"抖音"）。

**根因**：`Popover` 组件把浮层内容通过 `<Portal target={document.body}>`
渲染到了 `document.body` 下，脱离了 Select 自身的 DOM 子树。全局
`mousedown` 监听器判断"是否点击外部"时，只检查了
`rootNode.contains(event.target)`（`rootNode` 是 Select 最外层容器，不包含
Portal 渲染出去的浮层内容），点击浮层里的 `<li role="option">` 时这个判断
恒为 `false`——被误判为"点击了外部"。而浏览器原生事件顺序是
`mousedown` 先于 `click` 触发，全局监听器在选项自己的 `onClick`
（真正执行"选中该项"逻辑的地方）触发之前就先把 `isOpen` 置为
`false`，连带把 `@if (displayVisible) {...}` 条件渲染的选项列表从 DOM
上摘掉；等到浏览器该派发 `click` 事件时，原来的目标元素已经不在 DOM
里了，选项自己的 `onClick` 从未真正执行。表现出来就是"点击选项后浮层
关闭了，但值没变"这种介于"完全没反应"和"正常工作"之间的诡异状态，容易
被误判成响应式失效（这次排查早期确实先怀疑过是踩坑 #30 同类问题，排除
后才定位到真正原因）。

**修复**：除了 `rootNode`，再给浮层内容的根元素（这里是 `<ul class=
"lotus-select-list">`）加一个 `ref` 拿到它的 DOM 节点，全局 `mousedown`
判断时两个节点都要检查，只有两者都不包含点击目标才算"真正点击了外部"：
```tsrx
const list = untrack(() => listNode);
if (list?.contains(event.target)) return;
```

**结论性规则**：任何组件如果自己接管了 Popover/Dropdown 一类"内容通过
Portal 渲染到 document.body"的浮层开关状态（而不是用 Popover 内置的
hover/click toggle 语义），实现"点击外部关闭"逻辑时，判断范围必须覆盖
**触发器容器 + 浮层内容容器**两部分，只查触发器容器所在的 DOM 子树是不够
的——这是所有依赖 Portal 渲染浮层的组件（Select 之后的 Cascader、
TreeSelect、DatePicker、AutoComplete 等同样需要"选中后关闭 + 点击外部
关闭"的组件）都会遇到的通用问题，新组件设计这段逻辑时应直接对照这个
模式，不要重新独立踩一遍坑。

**排查方法论备注**：这次排查过程中，用 `computer` 工具（模拟真实鼠标）反复
点击同一个元素多次得到不一致的结果（有时展开、有时不展开），一度怀疑是
组件本身状态不稳定；最后定位到是两个独立原因叠加造成的干扰，都值得记录：
1. 页面滚动位置在多次工具调用之间会变化，之前用 `getBoundingClientRect()`
   查到的视口坐标缓存下来直接传给下一次点击操作，坐标失效导致点击命中了
   错误的元素——应该始终用 `find`/`ref` 重新定位，不要复用旧坐标。
2. Ripple 的 DOM 更新不是同步的，点击操作后立刻同步查询 `aria-expanded`
   等属性可能读到更新前的旧值；用 JS 程序化验证响应式状态变化时，操作和
   断言之间要留出至少几十毫秒的等待（或者用 Playwright 的
   `expect().toHaveAttribute()` 这类带自动重试的断言，不要用一次性的
   同步读取）。这两个问题都不是组件的真实 bug，但足以在排查过程中制造
   大量误导性的"复现"和"失败"，需要先排除工具/时序噪音，再下"这是真实
   bug"的结论。

## 踩坑 #34：Foundation 里并发校验多个字段时，`setState` 基于函数开始时的
旧快照 spread 合并，后完成的字段会覆盖先完成字段刚写入的值

**现象**：Form 组件的 `FormFoundation.validateAll()` 用 `Promise.all` 并发
校验所有已注册字段，每个字段各自跑完 `validateField` 后写回
`state.errors`。真机点击"提交"按钮触发全字段校验后，页面上只显示了
**最后一个**字段的错误信息，其余字段即使规则不通过，错误提示也不显示。
单测反而全部通过——因为既有单测只断言 `validateAll()` 的**返回值**（一个
在函数内部本地累加的 `results` 数组遍历构造出的对象），没有断言
`getState().errors` 这个真正被组件读取展示的存储状态。

**根因**：
```ts
async validateField(field: string): Promise<string | undefined> {
  const { values, errors } = this.getState();  // 函数开始时读一次
  const error = rules ? await validateRules(...) : undefined;  // 可能让出微任务
  this.setState({ errors: { ...errors, [field]: error } });  // 用旧 errors 合并
  return error;
}
```
`validateRules` 对 `validator` 类型的规则用了 `await`，即使所有规则都是
纯同步逻辑，函数体本身也至少经过一次微任务让出。`Promise.all` 并发调用
多个 `validateField` 时，每个调用都在**各自函数刚进入时**读了同一份旧
`errors` 快照；哪个字段先完成、就先把自己的 `error` 合并进这份旧快照写回
去；后完成的字段用的还是同一份最初的旧快照（不包含前面字段刚写入的
`error`），把自己的结果覆盖上去时会连带抹掉前面字段写入的内容。最终
`state.errors` 里只保留了最后一个完成的字段。

**修复**：`errors` 的读取必须挪到 `await` **之后**、写回**之前**，确保
每次合并用的都是当前最新状态，不是函数开始时的旧快照：
```ts
async validateField(field: string): Promise<string | undefined> {
  const { values } = this.getState();
  const error = rules ? await validateRules(values[field], values, rules) : undefined;
  const { errors } = this.getState();  // 写回前重新读，不用开局那份旧快照
  this.setState({ errors: { ...errors, [field]: error } });
  return error;
}
```

**结论性规则**：Foundation 里任何"读旧值 → 可能异步让出 → spread 合并写回"
的模式，只要写回前跨过了至少一次 `await`，读取旧值的时机就必须紧贴在写回
之前，不能用函数刚进入时的快照——这是 `Promise.all` 并发调用同一个方法时
的通用竞态陷阱，不止 Form 场景会遇到。单测覆盖这类并发写场景时，必须断言
`getState()` 的真实存储状态，不能只断言函数的返回值——返回值往往是调用方
自己在本地累加构造的，不会暴露底层存储状态被覆盖的问题。

## 踩坑 #35：Foundation 的 `reset()` 只恢复"显式声明过 initValue 的字段"，
遗漏了"只吃 Form 级 initValues、自己没有单独 initValue"的字段

**现象**：Form 有多个字段，其中只有 `username` 字段在 `<Field initValue=
"...">` 上显式声明了初值，`age`/`businessLine` 两个字段没有单独声明
`initValue`（只在 `Form` 的 `initValues={{ age: undefined, businessLine:
undefined }}` 里给了初值，且初值恰好是 `undefined`）。真机测试点击
"重置"按钮后，`username` 正确清空，但 `age`/`businessLine` 的展示值
纹丝不动。

**根因**：`FormFoundation` 内部维护的 `initValues` map，只在
`registerField(field, config, initValue)` 收到非 `undefined` 的
`initValue` 参数时才会写入这个字段的 key。`age`/`businessLine` 从未走过
这条写入路径（它们的初值只存在于 `Form` 挂载时对 `state.values` 的一次性
赋值里，Foundation 构造时如果不主动读取这份挂载快照，就完全不知道这两个
字段"曾经有过初值"），`reset()` 用 `{ ...this.initValues }` 覆盖
`state.values` 时，这两个字段的 key 根本不在 map 里，等于没有被重置。

**修复**：`FormFoundation` 的构造函数里，直接把 Adapter 传入的初始
`state.values`（也就是 Form 挂载那一刻的完整快照，天然包含 Form 级
`initValues` 里所有字段）整份拷贝作为 `initValues` 的起点，`register
Field` 里的显式 `initValue` 只是在此基础上补充/覆盖：
```ts
constructor(adapter: Adapter<FormState>) {
  super(adapter);
  this.initValues = { ...this.getState().values };  // 挂载快照，不局限于显式 initValue
}
```

**结论性规则**：任何"多字段容器"类 Foundation（Form 是目前唯一实例，
未来若有类似的多字段状态管理需求应参考此模式）的 `reset()` 语义，必须
恢复到**容器挂载那一刻的完整初始快照**，而不是"事后累积记录下来的、
局限于某个子操作触发路径的部分快照"——后者天然会遗漏那些从未走过该操作
路径、但确实拥有初值的字段。

## 踩坑 #36（重大）：`isControlled = value !== undefined` 判断受控身份如果
做成响应式、允许来回切换，组件内部 `state` 会残留"曾经非受控时写入"的
陈旧值，导致受控值变回 `undefined` 后展示值不会清空

**背景**：全项目 7 个组件（Input/InputNumber/Select/Switch/Checkbox/
Radio/TextArea）判断受控/非受控身份都用同一个模式：`const isControlled =
value !== undefined`（Checkbox/Radio 是 `inGroup || checked !== undefined`）。
这个判断历史上一直是**普通 `const`**，只在组件挂载时求值一次，此后
`value`/`checked` 无论怎么变化，组件都永久锁死在挂载时判定的模式——这在
"受控组件只接收非 `undefined` 的值、非受控组件的 `value` 从头到尾都是
`undefined`"这个此前所有调用方都遵守的隐含约定下，从未暴露过问题。

**现象**：Form 的 `Field` 组件把某个字段的 `value` 原样传给具体输入组件
（如 `<InputNumber value={value} ... />`），字段初始值是 `undefined`
（用户还没填），`InputNumber` 因此在挂载时把自己判定为**非受控**。用户
输入 "30" 后，Field 侧的 `value` 变为 `30` 并回传给 `InputNumber`；点击
Form 的"重置"按钮后，`value` 又变回 `undefined`，但 `InputNumber` 显示的
数字仍然是 "30"，没有被清空。

**排查过程**：第一轮修复尝试把 `isControlled` 从普通 `const` 改成
`track(() => value !== undefined)`（响应式 computed），让受控身份能随
`value` 变化重新判定——这一步单独看是必要且正确的（否则 `isControlled`
在挂载后永远不会重新求值，是比本条更基础的响应式缺陷）。但改完后 e2e
测试仍然复现同样的失败，说明问题不止"`isControlled` 该不该响应式"这
一层。

**真正根因**：`isControlled` 变成响应式后，组件会随 `value` 的变化在
受控/非受控身份之间**来回切换**：
1. 初始 `value=undefined` → `isControlled=false`（非受控），用户输入
   "30" 走非受控分支，`foundation.handleInput` 把组件**内部** `state.
   inputValue` 写成 `"30"`
2. `onChange(30)` 冒泡给 Field，`value` prop 变为 `30` → `isControlled`
   重新计算为 `true`（受控），此时展示逻辑 `isControlled ? String(value)
   : state.inputValue` 优先读 `value`，显示正确的 "30"
3. Form 重置，`value` 变回 `undefined` → `isControlled` 又变回 `false`
   （非受控），展示逻辑退回读 `state.inputValue`——但这个字段自步骤 1
   之后就再没被更新过，仍然是陈旧的 `"30"`

问题的本质是：**"受控/非受控身份可以动态切换"这个设计，与"内部 state
只在非受控分支被写入、受控分支完全不碰 state"这个假设互相冲突**——一旦
组件真的经历过"非受控写入 → 变为受控 → 又变回非受控"这个完整循环，第三
步读到的必然是第一步遗留的陈旧数据，不会自动跟着"受控期间外部实际传入
的值"同步。这不是 InputNumber 独有的问题，是 7 个组件共享的同一设计
缺陷，只是大多数既有用法从未把 `value` 从有值变回 `undefined`，所以从未
触发过。

**评估过的替代方案，为什么没采用**：
- **给组件加显式 `controlled?: boolean` prop**：增加 API 复杂度，且与
  隐式的 `value !== undefined` 判断容易打架（两者不一致时听谁的？），
  否决。
- **用 React `key` 那样的"强制重新挂载"机制清空内部 state**：Ripple 没有
  这个机制——`key` 只在 `@for` 循环里用于列表 reconciliation，不存在
  组件级别"换个 key 就整个重新初始化"的语义，否决（除非把目标组件包一层
  `@for` 循环模拟，过于 hacky）。
- **要求调用方永远不要把受控 `value` 设为 `undefined`（用空字符串/`0`
  等哨兵值代替）**：这是 React 生态的通行文档建议，Semi 官方 `withField`
  文档示例也是这么处理的（`let value = props.value || '';`）。但
  `InputNumber`/`Select` 的值域里没有天然的"空但非 `undefined`"哨兵值
  （`InputNumber` 是纯数字类型不能塞空字符串，`Select` 的 `SelectValue`
  是 `string | number` 联合类型也没有通用空值），这条路对这两个组件
  根本走不通，只能作为 `Input`/`TextArea` 这类天然有 `''` 可用的组件的
  兜底文档建议保留，不能当作全项目统一方案。

**采用的修复**：保留 `isControlled` 的响应式 track 化（这一步本身是
必要的），额外加一个 `effect`，让组件内部 `state` **始终跟随最近一次
外部受控值同步**，不管当前是否处于受控分支——这样即使身份来回切换，
`state` 里存的也不会是陈旧数据：
```ts
// InputNumber 的具体实现，其余 6 个组件是同样模式（state 字段名不同）
let &[hasBeenControlled] = track<boolean>(false);
effect(() => {
  if (value !== undefined) {
    hasBeenControlled = true;
    untrack(() => { state = { ...state, inputValue: String(value), value }; });
  } else if (untrack(() => hasBeenControlled)) {
    untrack(() => { state = { ...state, inputValue: '', value: undefined }; });
  }
});
```
`hasBeenControlled` 这个标记是关键——区分"这次 `value===undefined` 是
一开始就非受控（用户在自由输入，不该打扰）"还是"曾经受控过、现在被外部
清空（要主动同步清空 `state`）"，否则会误伤纯非受控用法下用户正常输入
的场景。

**effect 内部读写同一个 state 变量的死循环陷阱**：第一版实现里，
`state = { ...state, ... }` 这个赋值表达式右侧的 `{...state}` 展开是在
`effect` 内部**非 `untrack` 地读取** `state`，而这个 effect 本身又写了
`state`——构成"读自己刚写的值 → 被记为依赖 → 又触发自己重新执行"的自
触发循环，真机报错 `Maximum update depth exceeded`。修复：整个赋值语句
包进 `untrack(() => { state = {...} })`，确保 `state` 的读取不被这个
effect 记为依赖，只有 `value`（外部 prop）才是这个 effect 的真实依赖。

**结论性规则**：
1. 任何组件的 `isControlled`/`isChecked` 类身份判断，只要依赖的是可能
   变化的 prop（`value`/`checked`），一律必须用 `track()` 响应式
   computed，不能用普通 `const`——这是比 `&{}` 懒解构（踩坑 #30）更深
   一层的响应式正确性要求，两者缺一都会导致受控组件对外部 prop 变化
   不敏感。
2. 如果组件设计允许"受控身份动态切换"（大多数受控组件事实上都允许，
   因为 `value` prop 本身就可能在 `undefined` 和有值之间变化），必须
   同时保证内部 `state` 不会在身份切换后残留陈旧数据——用一个 `effect`
   把外部受控值同步进内部 `state`（哪怕当前正处于受控分支、这份 state
   暂时不会被展示逻辑读到），是目前验证有效的做法。
3. `effect` 内部如果要读取自己也会写入的同一个响应式变量做增量更新
   （`{...state, patch}` 这种 spread 合并模式在 `effect` 里非常常见），
   读取部分必须包 `untrack`，否则会形成自触发死循环——这条规则和 Foundation
   侧 `getState()`/`setState()` 通常搭配 `untrack` 使用是同一个道理，
   只是这次踩在了组件自己手写的 `effect` 里，而非 Foundation 样板代码里。
4. **任何新的受控组件（或者复用这套 `isControlled` 模式的既有组件二次
   开发），如果要支持"字段初始值为 `undefined`"这个场景（Form/Field
   这类通用容器天然会遇到），开发时必须专门测试"受控值 `undefined` →
   有值 → 变回 `undefined`"这个完整循环，不能只测"有值 → 变成另一个
   有值"这种单向变化**——后者掩盖了本条踩坑的全部症状。

## 踩坑 #37：Ripple 没有 React 那种"把函数当 prop 传入、组件内部直接调用
它拿返回值"的 render-prop 机制，组件只能作为整体传递并用 `<Comp />` 渲染

**现象**：设计 Form 的 `Field` 组件时，最初想用 React 生态常见的
render-prop 模式——`Field` 接收一个 `children: (props: FieldRenderProps)
=> any` 函数类型的 prop，内部 `{children({ value, onChange, ... })}`
调用它、把 `value`/`onChange` 等注入进去，调用方在 `children` 里正常
声明要渲染的具体输入组件。`tsrx-tsc` typecheck 直接报错：`children
cannot be called like a regular function. Render it with {children} or
{props.children} instead.`

**根因**：Ripple 里 `children` prop（以及任何"组件类型"的 prop）本质上
是一个**已经确定了内容、可以直接 `{children}` 渲染的东西**，不是"一个
在渲染时才被调用、根据传入参数动态生成内容的函数"。官方文档
`components.md` 的 "Passing Components as Props" 一节明确了这一点：
组件只能作为**显式 prop** 整体传递，用 `<PropComp />` 这样的 JSX 语法
渲染，不能当普通函数调用（`children(...)`/`PropComp(...)`）拿返回值。

**修复**：把 `Field` 的 `children: (props) => any` 改成一个独立命名的
prop `Comp: (props: FieldRenderProps) => any`，调用方传入一个组件（不是
调用它、也不是它的返回值），`Field` 内部用 `<Comp value={value}
onChange={handleChange} ... />` 这样的 JSX 语法渲染它，参数通过 JSX
属性传递：
```tsrx
// Field 内部
<Comp value={value} disabled={disabled} onChange={handleChange} onBlur={handleBlur} aria-label={resolvedLabel} />
```
调用方（业务代码，如 playground）需要为每个具体输入组件写一个"桥接
组件"，接收 `FieldRenderProps` 形状的 props，桥接到具体组件（Input/
Select/Checkbox 等）各自不同的 `onChange` 签名上：
```tsrx
function FormUsernameInput(&{ value, disabled, onChange, onBlur, 'aria-label': ariaLabel }: FieldRenderProps) {
    return <Input value={value ?? ''} disabled={disabled} onChange={(v) => onChange(v)} onBlur={onBlur} aria-label={ariaLabel} />;
}
```

**类型标注的额外陷阱**：如果用 Ripple 提供的 `Component<T>` 类型标注
`Comp` 的类型（`Comp: Component<FieldRenderProps>`），typecheck 会报
`Component<FieldRenderProps>` 不能赋值给 JSX 组件类型——因为 `Component<T>`
的返回类型是 `Renderable | void`，而 `Renderable` 包含 `null`，JSX
组件类型系统期望的 `ComponentType` 只接受 `void | TSRXElement`，两者有
落差。规避方式：用更宽松的 `(props: FieldRenderProps) => any` 做类型
标注，不用官方导出的 `Component<T>` 类型。

**结论性规则**：设计任何需要"父组件把数据注入进子组件渲染逻辑"的 API
时（render-prop、slot、compound component 等模式在 React/Vue 生态很
常见），Ripple 下必须用"组件作为显式 prop + `<Comp {...props} />` 渲染"
的形态，不能设计成"把函数当 prop、调用它拿返回值"的 render-prop 写法。
这是继 Nav 组件"用独立命名导出组件替代 `Nav.Item` 挂载写法"（Ripple
无 children 反射能力）之后，Ripple 语言约束在 API 设计层面暴露出的
又一处需要"诚实设计取舍"的地方——不是缺陷，是与 React 心智模型不同的
组件传递范式，设计新组件 API 时要提前对齐这个约束，而不是先按 React
习惯设计、写到一半才发现行不通。

## 踩坑 #38：i18n 基础设施搭建——Foundation 层的默认文案不能依赖
`@lotus/locale`，必须作为可注入参数；locale 切换后已显示的错误信息
需要主动重新校验才会更新

**背景**：项目此前 6 个 Phase 1 组件（Input/InputNumber/Checkbox/Radio/
Switch/Form）的所有面向用户文案（"清除"、"显示密码"、Form 校验默认
错误信息等）全部硬编码中文，`packages/locale` 包和 `ConfigProvider`
横切基础设施此前从未搭建过。这是本次从零搭建时踩的两个坑。

**坑一：Foundation 层不能依赖 `@lotus/locale`**。虽然 `@lotus/locale`
是纯数据包、不依赖 Ripple 运行时，技术上 Foundation import 它不会产生
真正的循环依赖或框架耦合，但这违背了 Foundation/Adapter 分层的设计
初衷——Foundation 应该只依赖自己声明的最小契约类型，不应该反向依赖任何
"面向 UI 层的横切包"，否则未来每新增一个横切能力（主题、埋点、权限）都
会诱使 Foundation 逐渐堆积一堆横切依赖，分层形同虚设。正确做法：
Foundation 声明自己的 `FormMessages` 接口（最小契约，只含用到的字段），
默认值给一份内置的中文兜底常量（`DEFAULT_MESSAGES`），实际文案由
`.tsrx` 侧从 `LocaleContext` 读取 `locale.Form` 后，作为参数显式传给
`validateField(field, messages)`/`validateAll(messages)`/`submit(...,
messages)`——这些方法签名新增了 `messages` 参数但给了默认值，不破坏
既有调用方。

**坑二：locale 切换后，已经显示在页面上的旧错误信息不会自动更新**。
`specs/cross-cutting/i18n-locale.spec.md` 明确要求"Form 组件切换
locale 后，校验错误文案实时更新（不需要重新挂载组件）"。真机验证时
发现：先触发一次校验产生中文错误提示，再切换 `ConfigProvider` 的
`locale` prop 到英文，页面上的错误文案**纹丝不动**，还是中文——因为
`state.errors[field]` 存的是校验时刻已经算出来的**字符串结果**，不是
对 `messages` 的引用，locale 变化不会让这个字符串自动重新翻译，只有
下次用户重新触发 blur/submit 校验时才会用上新文案。

**修复**：在 `Form` 组件内部用 `effect()` 监听 `messages`（响应式，从
`LocaleContext` 派生）的变化，一旦变化就对`state.errors` 里当前所有
非空的字段重新跑一次 `foundation.validateField(field, newMessages)`：
```tsrx
effect(() => {
    const currentMessages = messages;  // 响应式读取，建立依赖
    const fieldsWithError = Object.keys(untrack(() => state).errors)
        .filter((field) => untrack(() => state).errors[field]);
    fieldsWithError.forEach((field) => {
        foundation.validateField(field, currentMessages);
    });
});
```
只对"当前已经有 error 的字段"重新校验，不是无脑对全部已注册字段重新
校验——没有错误的字段没有旧文案需要更新，全量重新校验是不必要的浪费。
`effect` 内部读 `state.errors`（判断哪些字段需要重算）必须包
`untrack`，只让 `messages` 成为这个 effect 的真实依赖，否则
`validateField` 写回 `state.errors` 会让这个 effect 因为读了自己刚写
的 `state` 而重新触发，形成踩坑 #36 那种死循环。

**结论性规则**：
1. 任何 Foundation 方法如果需要用到"面向用户展示的文案"，一律通过方法
   参数注入（可以给合理的默认值保持向后兼容），不能让 Foundation 反向
   依赖 `@lotus/locale` 或任何 UI 横切包——这是分层纪律，不是技术限制。
2. 任何"结果是从当前 locale 文案计算出来、但计算结果被缓存/存储下来"
   的场景（校验错误信息只是第一个实例，未来 DatePicker 的月份名称、
   格式化后的日期字符串等都是同类场景），locale 切换后如果不主动
   重新计算，缓存的旧文案不会自动更新——设计新组件时要主动检查"这个
   组件是否存储了任何从文案派生出的字符串"，如果有，就需要类似这里的
   "监听 locale 变化、重新计算已缓存内容"的 effect。
3. `ConfigProvider`/`LocaleContext` 归属 `other/` 分类（对齐
   `AGENTS.md` 的组件分类目录约定），不是随便塞进某个具体组件目录——
   所有需要消费 locale 的组件统一从
   `../../other/config-provider/locale-context.js` 引入
   `LocaleContext`，`fallback` 到 `zhCN`（对齐项目历史上所有硬编码
   文案都是中文这一事实）。

## 踩坑 #39（重大）：`apps/docs/ripple.config.ts` 从 `@ripple-ts/vite-plugin`
值 import `RenderRoute` 类，dev 模式下把整套服务端渲染逻辑打包进客户端，
导致 `onClick` 类交互全站失效——真正根因不在这里，是 #40 的连带效应

**背景**：这是继踩坑 #9（`defineConfig` 值 import 触发 `process.platform`
崩溃）之后，同一个文件里的第二处"值 import 上游包、拖出不该在客户端跑的
服务端逻辑"。`apps/docs/src/routes.ts` 里 `import { RenderRoute } from
'@ripple-ts/vite-plugin'`，这个包的主入口 `src/index.js` 顶层 `import` 了
`./server/router.js`、`./server/middleware.js` 等一整条服务端渲染/路由/
中间件实现。Vite dev 模式用原生 ESM、不做 tree-shaking，`virtual:ripple-
hydrate` 客户端入口脚本 `import rippleConfig from "/ripple.config.ts"`
时，会把这份配置文件（连带它 import 的 `routes.ts`、连带 `RenderRoute`
所在的整个 `@ripple-ts/vite-plugin` 主模块）完整加载执行一遍。

**排查中的关键弯路**：真机验证发现，`process.platform` 崩溃修复后，
`Input` 组件的受控输入（`onInput`）恢复正常，但 `Switch`/`Button`/
`InputNumber` 步进器这类 `onClick` 交互依然完全失效——用 CDP
`DOMDebugger.getEventListeners` 确认 `#root` 节点上根本没有挂载任何
`click` 委托监听器。一度怀疑是 `RenderRoute` 类值 import 拖出的服务端
逻辑污染了 Ripple 事件委托系统的模块级状态（`all_registered_events`/
`root_event_handles`），把 `routes.ts` 改成 plain object 代替
`new RenderRoute(...)` 实例后，`#root` 上确实出现了完整的事件监听器
集合（含 `click`），但页面却完全无法渲染——`module server` 的 RPC 机制
报 `500 Invalid input`（`devalue.parse` 反序列化失败）。这个"修复"比
原问题更严重，被迫回滚。

**真正根因（见踩坑 #40）**：`onClick` 失效和 RPC 500 都只是**表象**，
真正的根因是 `module server` 的 `loadDoc()` 在客户端是异步 RPC 调用，
但所有 docs 页面组件都写成了 `const doc = loadDoc();` 这种假设同步返回
的用法。这个不匹配从项目一开始就存在，只是`process.platform` 崩溃
总是抢在 hydrate 真正执行到 `loadDoc()` 这行代码之前就让整个客户端脚本
顶层执行中断，所以从未暴露。修完 `process.platform` 崩溃后，hydrate
第一次真正跑到这行代码，暴露出真正的 bug；而这次暴露出的报错信息
（`Cannot read properties of undefined (reading 'category')`）表面上
看起来像是"数据没传对"，牵connect到 `routes.ts`/`RenderRoute` 上是
一次误诊——`RenderRoute` 类本身对 SSR/RPC 路由匹配是必需的（`plain
object` 替代版本破坏了 RPC，不是巧合，是因为 RPC handler 的注册收集
逻辑确实依赖了完整正确的路由配置），只是这个巧合掩盖了真正的异步/
同步不匹配问题——`RenderRoute` 类版本下，`process.platform` 崩溃仍在
（因为它本身没被修，这份分析针对的是"如果只改 routes.ts 不改
`ripple.config.ts`"的中间态），页面提前失败 fallback 到 `mount()`，
`mount()` 阶段同样会调用一次 `loadDoc()`，同样命中同步/异步不匹配，
但因为整个客户端脚本更早地在别处失败，这个特定错误被更早的错误链
掩盖，没有独立浮现。

**结论性规则**：本条本身不是需要修的 bug——`RenderRoute` 类值 import
是必需的，不能替换成 plain object（会破坏 RPC handler 注册）。真正的
教训是**排查连环故障时，第一个修复解除的崩溃可能只是掀开了更深一层
从未被验证过的代码路径**——process.platform 崩溃修复后代码能往前走了，
反而暴露出一个从项目最初就存在、从未被测试覆盖到的 `module server`
异步用法错误。诊断这类"修一个问题、冒出另一个更怪异问题"的场景时，
要优先怀疑"新暴露的错误是被之前的错误一直挡在门外的独立缺陷"，而不是
"这次改动引入的新问题"——两种假设都要用最小复现验证，不能只凭直觉
下结论（本条踩坑的教训就是最初误判了方向，多花了不少排查时间）。

## 踩坑 #40（重大）：`module server` 的客户端桥接函数是异步 RPC 调用，
docs 站全部 17 个页面组件都用 `const doc = loadDoc();` 同步写法，
必须改成 `trackAsync` + `@try`/`@pending` 异步边界

**现象**：`apps/docs` 每个文档页面组件都用 `module server { export
function loadDoc() {...} }` + `import { loadDoc } from server;` +
`const doc = loadDoc();` 的写法，从项目最初的 Input/Switch 两个页面
到本轮新增的 5 个页面、以及后续补的另外 13 个既有页面，全部 17 个页面
统一踩了同一个坑——这个 bug 一直存在，只是从未被真机验证覆盖到（此前
docs 站的验证止步于"页面能渲染出 HTML"，没人真正点击测试过交互，
`specs` 踩坑 #9 的记录里也明确写过"`apps/docs` 站当前所有交互类组件
demo 在浏览器里均不可点击验证"——这次修复过程正是在尝试解决 #9 遗留
的这句话时，牵连出了这个更深层的独立问题）。

**根因**：`packages/ripple/src/runtime/index-client.js` 里客户端的
`rpc()` 桥接函数（`packages/ripple/src/runtime/internal/client/rpc.js`）
是 `export async function rpc(hash, args)`——**永远返回 Promise**，
这是 RPC 调用的本质决定的（跨网络请求不可能同步）。`module server`
编译器会把 `import { loadDoc } from server;` 在客户端编译成对这个
`rpc()` 函数的调用。但页面组件代码里 `const doc = loadDoc();` 把返回值
当同步对象直接用（`doc.frontmatter.category`），在服务端 SSR 阶段
（`loadDoc` 是直接函数调用，真同步）这样写没有问题，但客户端 hydrate
阶段执行到这行代码时，`doc` 实际上是一个 `Promise`，`doc.frontmatter`
是 `undefined.frontmatter`，抛出
`TypeError: Cannot read properties of undefined (reading 'category')`。

**修复**：改用 Ripple 官方提供的 `trackAsync` + `@try`/`@pending`
异步边界模式（`ripple` 包顶层导出）：
```tsrx
import { Fragment, trackAsync } from 'ripple';

module server {
  import { getDoc } from '../../lib/markdown';
  // 必须显式声明 async，否则客户端桥接层不会把这个函数当异步处理，
  // trackAsync(() => loadDoc()) 的类型也无法正确推导成 Promise<T>。
  export async function loadDoc() {
    return getDoc('input/switch');
  }
}

import { loadDoc } from server;

export function SwitchDocPage() @{
  let &[doc] = trackAsync(() => loadDoc());

  @try {
    <DocsLayout category={doc.frontmatter.category} ...>
      {/* ... */}
    </DocsLayout>
  } @pending {
    <p>Loading...</p>
  }
}
```

**两个不能省的细节，各自都会导致完全不同的报错**：
1. **`module server` 里的函数必须显式标 `async`**：`export function
   loadDoc()`（非 async）即使客户端确实通过 `rpc()` 异步调用它，
   TypeScript 类型层面 `loadDoc` 的返回类型仍然是同步的 `RenderedDoc`
   而非 `Promise<RenderedDoc>`，`trackAsync(() => loadDoc())` 会在
   typecheck 阶段报类型不匹配（`trackAsync` 要求参数返回
   `PromiseLike<V>`）。加上 `async` 后类型自动变成
   `Promise<RenderedDoc>`，`trackAsync` 类型对齐，且不需要手写
   `ReturnType<typeof loadDoc>` 之类的辅助类型。
2. **`trackAsync` 的声明和对其字段的读取，必须都在同一个 `@try {}`
   块的直接子级里，不能拆成"外层 `@try` 包一个内层子组件，子组件内部
   再声明 `trackAsync` 并读取"**——最初尝试过这种更符合直觉的拆分写法
   （外层页面组件只负责 `@try`/`@pending`，实际数据获取和渲染放进一个
   独立的内层组件），运行时报
   `Reads on pending tracked values directly inside component body
   are prohibited`。根源在 Ripple 运行时对"pending 值合法读取位置"的
   检测（`runtime.js` 的 `is_try_fn_block` 判断）要求当前渲染块的
   父级就是 `TRY_BLOCK`——`trackAsync` 声明和读取都必须直接摆在
   `@try {}` 大括号里的最外层语句序列，不能再套一层组件调用把它们
   分隔开。

**验证方法**：真机验证必须覆盖"点击某个依赖 `module server` 数据渲染出
的交互元素、断言状态真的改变"这个完整链路，不能只看"页面渲染出了
HTML"（SSR 输出永远是完整的，因为 `loadDoc` 在服务端是真同步调用，
这条路径从未暴露过问题——只有客户端 hydrate 之后的交互才会命中这个
bug）。本次用 `ego-browser` 的 CDP `DOMDebugger.getEventListeners`
确认 `#root` 事件监听器集合、`Network.responseReceived` 确认 RPC 请求
真实状态码与响应体内容、点击后断言 `aria-checked`/`value` 等属性真的
变化，三层证据链交叉验证，才最终定位到这是"数据获取模式"问题而不是
"事件委托"问题——排查过程中一度被"`#root` 上确实没有 `click` 监听器"
这个表面证据带偏方向，误以为要修事件委托系统本身。

**结论性规则**：
1. **任何新增的 docs 页面，只要用了 `module server` 声明的数据获取
   函数，一律必须用 `async function` + `trackAsync` + `@try`/
   `@pending` 模式，不能写成看起来更简单的同步 `const doc =
   loadDoc();`**——这个错误在服务端渲染阶段完全不会暴露，只有真机
   点击测试客户端 hydrate 后的交互才会发现，非常容易被"页面能正常
   显示"的表面现象糊弄过去。
2. `trackAsync` 的声明变量和对它的属性访问，必须摆在同一个 `@try {}`
   块的最外层直接语句里，不能拆分到被 `@try` 调用的子组件内部。
3. 排查"页面能渲染但不能交互"这类问题时，`curl` 直接请求 SSR HTML
   可以确认服务端渲染本身是否正常（本次验证 SSR 输出始终完整，问题
   只在客户端 hydrate 之后），是快速排除"服务端渲染逻辑本身有问题"
   这个方向、把排查范围收窄到"客户端 hydrate/交互层"的有效手段。

## 踩坑 #41：`@if (cond) {...} @else {...}` 两个分支都渲染同一 class 名的
容器元素时，`@else` 分支内容不显示，拆成两个独立 `@if` 后正常

**现象**：`IconButton` 组件按钮内部结构写成
```tsrx
@if (loading) {
    <span class="lotus-icon-button-icon"><SpinnerIcon /></span>
} @else {
    <span class="lotus-icon-button-icon">{icon}</span>
}
```
`loading=false`（默认非加载态）时，用 `ego-browser` 检查真实 DOM，
`<span class="lotus-icon-button-icon">` 元素存在，但 `childNodes` 为空——
`{icon}` 传入的 `<IconSetting />` JSX 完全没有渲染出来，`textContent`
和内部 `innerHTML` 均为空字符串。`icon` prop 本身确认有效传入（同样的
`icon={<Xxx />}` 写法在已验证工作的 `DropdownItem`/`Tag` 组件里正常
渲染），排除了 prop 传递层面的问题。

**排查过程**：
1. 先怀疑是否需要额外包一层容器（Tag 的 `prefixIcon` 写法本身就是
   `<span>{prefixIcon}</span>`），改写后问题依旧，排除"裸露 `{icon}`
   插值需要包裹"这个假设——事实上原代码已经包了 `<span>`。
2. 用 `curl` 直接取 Vite 提供的源文件确认改动已生效、非缓存问题。
3. 对照检查逻辑完全同构的 `DropdownItem`（`@if (icon != null) { <span
   class="...">{icon}</span> }`，是单独 `@if` 而非 `@if/@else` 结构，
   工作正常。
4. 将 `IconButton` 的 `@if/@else` 改写成两个条件互斥的独立 `@if`
   （`@if (loading) {...}` + `@if (!loading) {...}`），问题立即消失，
   `{icon}` 正确渲染成 `<svg>`。

**根因（未深挖到编译器内部实现，仅记录现象与规避方式）**：当 `@if` 和
`@else` 两个分支渲染的是**结构相同、class 名相同的容器元素**（这里是
两个分支都输出 `<span class="lotus-icon-button-icon">`）时，Ripple
编译器/运行时在分支切换的 diff 逻辑上疑似对这种"节点态"复用产生了
错误判断，导致 `@else` 分支的子节点更新丢失。`SpinnerIcon`/`icon`
两个分支内容结构不同（一个是 `<svg>`、一个是任意 JSX），但外层 `<span>`
的 class 完全一致，是本次触发条件的关键差异点（`DropdownIton` 对照组
只有一个分支、没有 `@else`，天然不会触发这个问题）。

**规避方式**：**两个分支渲染的容器元素即使 class 相同，也不要用
`@if/@else` 二选一结构，改成两个条件互斥的独立 `@if` 块**（`@if (a)
{...}` + `@if (!a) {...}`）。这是本次验证中唯一确认有效的 workaround；
未验证"两个分支加不同 class 是否也能规避"，遇到类似问题优先直接套用
"拆成独立 `@if`"这个已验证方案，不必重新排查。

**验证方法**：这类问题 **SSR 阶段和"看起来渲染出了 HTML"都不会暴露**
——本次是用 `ego-browser` 的 `js()` 直接读取 `element.outerHTML`/
`childNodes` 才发现 `<span>` 是空的（外层元素结构正确，掩盖了内部内容
缺失）。任何新组件只要用到 `@if/@else` 且两分支输出结构接近，验收测试
必须真机检查渲染出的 DOM 内部内容（不能只看外层容器/class 是否存在），
最可靠的方式是断言内部关键子元素（如 `<svg>`）确实存在。

## 踩坑 #42：`var(--lotus-xxx)` 引用不存在的 token 名不会报编译错误，
浏览器静默 fallback 成默认值，容易被"页面能正常渲染"糊弄过去

**现象**：`FloatButton` 组件开发时凭记忆/推测写了三个不存在的 token 名——
`--lotus-z-index-popup`（正确是 `--lotus-z-back-top`）、
`--lotus-border-radius-default`（正确是 `--lotus-border-radius-medium`）、
`--lotus-color-text-primary`（正确是 `--lotus-color-text-0`）。这三处
`var()` 引用均未触发任何 typecheck/lint/构建报错，页面也能正常渲染
（未定义的 CSS 自定义属性在 `var()` 里静默 fallback 为初始值/继承值，
等价于该条 CSS 声明被忽略），只有真机检查 `getComputedStyle()` 的实际
计算值才发现 `border-radius` 变成了 `0px`（而不是预期的 6px）。

**规避方式**：任何新写的 `var(--lotus-xxx)` 引用，写完后立即用一行命令
核对该 token 是否真实存在于 `packages/tokens/dist/tokens.css`：
```bash
grep -oE "var\(--lotus-[a-z0-9-]+" <组件文件路径> | sed 's/var(//' | sort -u | \
  while read t; do grep -q -- "${t#--lotus-}:" packages/tokens/dist/tokens.css \
  || echo "MISSING: $t"; done
```
不要凭记忆/语义联想拼写 token 名（例如想当然认为存在 `border-radius-
default`、`text-primary`），必须先 `grep packages/tokens/dist/tokens.css`
或读 `packages/tokens/src/static-tokens.ts` 源码确认真实键名。

**验证方法**：真机验证不能只看"元素是否可见/渲染出来"，对于依赖具体
token 值呈现视觉效果的场景（圆角、颜色、间距等），必须用
`getComputedStyle(el).xxx` 读取浏览器真实计算值，与预期 token 值比对，
才能发现这类静默失败。

## 踩坑 #43：开发中频繁编辑代码时，`ego-browser` 复用同一个浏览器 tab
可能停留在陈旧的模块缓存上，表现得和真实渲染 bug 一模一样，浪费大量
排查时间；Playwright 拖拽类测试必须先 `scrollIntoViewIfNeeded()` 再取
`boundingBox()` 坐标

**现象一（dev server/tab 缓存假象）**：开发 `Resizable` 组件时，playground
里新增的演示区块在真机验证时完全不渲染（相邻的调试文本标记也一并消失），
但 `curl` 直接请求 Vite 源码接口、`typecheck`/`lint` 全部正常，怀疑是
运行时异常，用 `window.onerror`/`unhandledrejection`/`console.error`
拦截排查了一圈均未捕获到任何错误。用二分法逐步精简组件代码（去掉
`effect`、去掉 `@for`、去掉复杂 props）想定位触发点，发现无论怎么改，
浏览器里看到的内容都不变——回看实际渲染出的 class 名（`lotus-resizable-
debug`），发现这是几个版本之前、早就被覆盖掉的源码留下的产物。根因是
同一个 `ego-browser` 任务空间反复复用同一个浏览器 tab，Vite 的 HMR 在
高频连续保存（几秒内改十几次文件）时没有跟上，浏览器实际运行的是某个
中间态的陈旧模块，而不是当前磁盘上的最新代码。

**规避方式**：怀疑"改了代码但效果不变/更糟"时，不要立即假设代码有 bug
去做二分排查——先用 `curl` 对比 Vite 提供的源码接口内容与本地文件是否
一致（排除 Vite 侧缓存问题），若一致但浏览器行为仍不对，直接**重启 dev
server + 换用全新的 `useOrCreateTaskSpace` 任务空间名 + 全新 tab**
重新验证，比在旧环境里继续排查更快，且能避免被"陈旧代码产生的现象"
带偏方向做无用功。改动频繁的调试阶段，每隔几轮修改就应该重开一次全新
环境交叉验证，而不是无限信任同一个持续复用的 tab。

**现象二（Playwright 拖拽坐标）**：`Resizable` 组件的 e2e 测试里，用
`page.mouse.move/down/move/up` 模拟拖拽手柄，尺寸断言全部失败（拖拽前
后尺寸完全不变），但同样的拖拽操作用 `ego-browser` 的 `dragMouse` 助手
测试完全正常。排查发现 `class after mousedown` 里缺少 `lotus-resizable-
resizing`，说明 `mousedown` 事件根本没有命中手柄元素——`Resizable`
演示区块在 playground 页面靠下的位置，`handler.boundingBox()` 取到的
坐标是基于当前视口的绝对坐标，但页面在获取坐标和执行鼠标操作之间可能
仍处于滚动过程中，导致坐标与鼠标实际落点错位。

**规避方式**：任何需要精确坐标点击/拖拽的 Playwright 测试，取
`boundingBox()` 前必须先 `await locator.scrollIntoViewIfNeeded()`
让页面滚动稳定，再读取坐标、执行 `page.mouse` 操作序列。`locator.click()`
内部自带这个保护，但 `page.mouse.move/down/up` 这种手动坐标操作没有，
需要显式调用。

## 踩坑 #44（重大）：import 一个不存在的 `.tsrx` 文件时，Vite dev server
会静默卡死在启动阶段（不报错、不 ready），排查时极易误判为组件代码本身
的渲染 bug

**现象**：开发 Spin 组件时，为了做最小复现排查（把 Spin 组件临时替换成
极简调试版本），用 `mv` 把 `packages/ripple/src/feedback/spin/` 整个
目录移到 `/tmp` 做隔离测试，但 `packages/ripple/src/index.ts` 里
`export { Spin, ... } from './feedback/spin/index.tsrx';` 这行 import
语句还在、没有同步注释掉。此后无论怎么重启 dev server、换全新端口、换
全新 `ego-browser` 任务空间，`curl http://localhost:xxxx/` 都返回
`000`（连接失败）——Vite 进程本身能启动、能完成 "Scan complete" 阶段，
但永远卡在这之后、不再打印 "ready" 消息，也没有任何报错输出到 stdout/
stderr。花了大量时间怀疑是并发进程冲突（`pkill`/`kill -9` 反复清理端口
占用）、Ripple 编译器死循环、系统资源问题，最终用"把最近改动逐层
`git stash`/裁剪到已知能工作的版本，二分定位到具体哪个改动导致卡死"
的方法，才发现是这个悬空 import 路径。

**规避方式**：
1. **临时移动/删除某个正在被 `index.ts`（或其他文件）import 的目录做
   隔离测试时，必须同步临时注释掉对应的 import/export 语句**，否则
   Vite 卡死现象和真实的组件渲染 bug 表现完全不同（一个是 dev server
   彻底连不上、一个是页面能访问但内容缺失），排查方向会完全跑偏。
2. **`curl -s -o /dev/null -w "%{http_code}\n" http://localhost:xxxx/`
   返回 `000`（而不是发起过连接后超时）是一个强信号，指向"dev server
   进程本身没有真正完成启动"，而不是"页面内容有问题"**——遇到这个信号
   应该优先检查最近改动是否有 import 指向了不存在的路径，而不是去怀疑
   组件渲染逻辑。
3. 排查"改了代码但环境行为异常"类问题时，`git stash` 是比手动逐行注释
   代码更快、更不容易引入二次污染的隔离手段——`git stash pop` 后如果
   环境恢复正常，再用 `git stash show -p` 逐段回放改动，能比较快定位到
   具体是哪一行改动触发的异常。
4. **同一类"dev server 卡死不报错"现象也可能来自 Vite 的
   `node_modules/.vite` 依赖预打包缓存损坏，不一定是悬空 import**——
   开发 Banner 组件时排除了悬空 import 后依然卡死，`rm -rf
   <app>/node_modules/.vite` 清理依赖预打包缓存后问题消失。遇到
   `curl` 返回 `000` 且确认没有悬空 import 时，下一步就是清理这个
   缓存目录重试，而不是继续怀疑组件代码本身。

## 踩坑 #45（重大）：Foundation 的 `getState`/`setState` 适配器实现里，
`setState` 内部展开 `...state` 若不经过 `untrack()` 包裹，会在
`effect()` 中触发"读写同一状态"的无限循环（`Maximum update depth
exceeded`），且这个 bug 在纯 SSR/静态渲染下完全不会暴露

**现象**：`Spin` 组件的 Adapter 层写成
```tsrx
const foundation = new SpinFoundation({
    getState: () => state,                                          // ❌ 未 untrack
    setState: (patch) => { state = { ...state, ...patch }; },        // ❌ 展开 state 未 untrack
});
effect(() => {
    foundation.syncFromProps(spinning, delay);   // 内部会调用 setState
});
```
真机点击测试（点击按钮把 `spinning` 从 `true` 切到 `false`）时，浏览器
控制台抛出 `Error: Maximum update depth exceeded. This typically
indicates that an effect reads and writes the same piece of state.`，
页面卡死。**页面首次渲染完全正常**（初始 `effect()` 执行时 `spinning`
不变化，不会触发 `setState` 里对 `state` 的读取被计入依赖），只有当
`spinning`/`delay` 变化、`effect()` 重新执行、内部再次调用
`setState` 时，才会因为 `setState` 展开 `...state`（读取了 tracked
状态）而被 Ripple 运行时判定为"这个 effect 同时读写了 state"，触发
死循环兜底报错——这与本文档踩坑 #36 是同一根因，但触发路径不同（#36
是 `getState()` 未 `untrack`，这次是 `setState` 内部 `...state`
展开同样需要 `untrack`）。

**规避方式**：**Foundation 适配器的 `getState` 和 `setState` 两个实现
都必须用 `untrack(() => state)` 包裹对 `state` 的读取**，没有例外：
```tsrx
const foundation = new XxxFoundation({
    getState: () => untrack(() => state),
    setState: (patch) => { state = { ...untrack(() => state), ...patch }; },
});
```
这是本文档「通用范式」章节已经写明的规则，但因为 `setState` 单行写法
不易察觉自己在"读 state"（`...state` 展开在视觉上不如 `getState`
那样显眼），后续组件开发容易在照抄样板代码时漏掉 `setState` 里的
`untrack`，需要作为新组件 code review 的显式检查项。

**验证方法**：这类 bug **必须通过"prop 值变化后再次触发副作用"的真机
交互测试**才能暴露，纯渲染快照/首次挂载测试完全不会命中——任何组件的
e2e 测试只要涉及"点击按钮驱动 prop 变化，断言组件响应式更新"的场景
（例如本文档反复强调的"外部按钮驱动受控 prop 变化"测试模式），天然
就会覆盖到这类死循环 bug，这也是为什么这类测试模式被反复要求的原因
之一——它不仅验证功能正确性，还顺带验证了响应式实现本身没有循环依赖。

## 踩坑 #46：新组件内部复用已有组件（如 Banner 复用 IconButton 做关闭按钮）
会让存量 e2e 测试里的泛化 class/aria-label 选择器意外命中新增元素，
触发 Playwright 严格模式报错

**现象**：新增 Banner 组件后，全量跑 e2e 时此前一直通过的
`e2e/basic/icon-button.spec.ts` 里一条测试开始稳定失败——`Banner`
的关闭按钮内部复用了 `IconButton`（`size="small"`、`aria-label="关闭"`
均为默认/常见值），旧测试里 `page.locator('.lotus-icon-button-size-
small')`（选择所有 small 尺寸图标按钮）和 `page.getByRole('button',
{ name: '关闭' })`（选择 aria-label 为"关闭"的按钮）两个选择器，从
"只命中 playground 里那一个 IconButton 演示实例"变成"同时命中 Banner
关闭按钮"，Playwright 严格模式判定为多义选择器报错。

**规避方式**：组件库内部一个组件复用另一个组件是完全正常、值得鼓励的
设计（IconButton 复用 Button 的 Foundation、Popconfirm 复用 Popover、
Banner 复用 IconButton 均是如此），但这意味着**任何新组件只要内部用到
了已有组件，都可能让该已有组件在页面上的实例数量意外增加**。写 e2e
测试时：
1. 优先用具体的 `aria-label`/文本内容而不是泛化的 class 选择器定位
   演示区块里的特定实例。
2. 当预期的 `aria-label`/文本可能与其他组件内部复用产生的实例重名
   时（如通用的"关闭"“确定"“取消"），追加区分性的 class/属性组合
   限定范围（如 `button.lotus-icon-button-theme-solid[aria-label="关闭"]`），
   不要仅凭直觉认为某个 label 在整个 playground 页面里是唯一的。
3. **每次新组件开发完成后，除了跑该组件自己的 e2e，必须跑一次全量
   `pnpm test:e2e`**——这类因内部组件复用触发的选择器冲突，只有全量
   跑才会暴露，单独跑新组件或旧组件各自的测试文件都不会发现。

**同族案例（Card 组件，比 aria-label 重名更隐蔽的一种形式）**：Card
组件内部复用了 `Skeleton`/`SkeletonTitle`/`SkeletonParagraph` 做
`loading` 占位。playground 里 Card 演示区块插入的位置在 DOM 顺序上
早于既有的 Skeleton 专属演示区块，导致 `packages/foundation` 那批
存量 e2e 测试里 `page.locator('.lotus-skeleton').first()` 和
`.locator('.lotus-skeleton-paragraph').first()` 这类"隐式依赖页面
唯一实例/隐式依赖 DOM 顺序"的选择器，从命中 Skeleton 自己的演示
实例变成了命中 Card 新插入的 loading 占位实例——不是"选择器命中
多个元素报严格模式错误"，而是"`.first()` 悄悄换了目标"，某些断言
因为两个实例结构恰好相似（如都是 3 行、末行更窄）会碰巧仍然通过，
另一些断言（如"应该有 avatar 子元素"）会失败得莫名其妙。**根治
方式是给所有可能被复用的展示型组件补齐 `aria-label` prop 支持**
（本次同时给 `SkeletonProps`/`SkeletonParagraphProps` 补上了这个
字段），存量测试改用 `getByLabel` 取代 `.first()`/裸 class 选择器。
这提示一个更通用的教训：**新组件设计阶段就应该给每个会独立渲染出
DOM 节点的展示型子组件都预留 `aria-label` prop**（哪怕当前用不到），
不要等到真机验证或全量回归失败才回头补——本次 `CardGroup`/`CardMeta`
两个子组件最初也漏了这个字段，独立的真机验证环节才发现。

## 踩坑 #47：`@for` 循环体内直接放 `@if (a) {...} @if (!a) {...}`
两个互斥分支（不包一层 `<>...</>`）时，`tsrx-tsc` 报
"A code block renders a single node" 编译错误

**现象**：`Pagination` 组件渲染页码列表时写成：
```tsrx
@for (const item of pageList; index i) {
    @if (item === '...') {
        <span class="lotus-pagination-item lotus-pagination-ellipsis">...</span>
    } @if (item !== '...') {
        <button ...>{item}</button>
    }
}
```
`pnpm typecheck` 报错 `A code block renders a single node; wrap
multiple nodes or text in a fragment '<>…</>'`，且错误信息不带行号，
只指向文件本身，一度需要靠"逐段注释排查"才定位到具体触发点。对照
`Steps` 组件的 `@for (const step of resolved; key ...) { <div ...>
...</div> }`（循环体直接是单个 `<div>`，编译通过）与 `IconButton`/
`FloatButton` 等组件里`@if (a) {...} @if (!a) {...}` 出现在**非
`@for` 循环体**位置（直接在组件顶层 `<>` 下）也编译通过，说明触发条件
是"`@for` 循环体的直接内容是多个 `@if` 分支"这个特定组合，而不是
`@if/@if` 结构本身、也不是 `@for` 本身。

**规避方式**：`@for` 循环体内如果需要按条件渲染不同元素（不是单一
固定结构），给整个条件分支序列包一层 `<>...</>` fragment：
```tsrx
@for (const item of pageList; index i) {
    <>
        @if (item === '...') {
            <span class="lotus-pagination-item lotus-pagination-ellipsis">...</span>
        } @if (item !== '...') {
            <button ...>{item}</button>
        }
    </>
}
```
`@for` 循环体只有单一固定结构（无分支）时不受影响，不需要额外包裹。

## 踩坑 #48（重大）：组件 props 解构里给"透传 spread 到子组件"的可选
props 不设默认值，值为 `undefined` 时 `{...undefinedValue}` 会让 Ripple
运行时崩溃（`Cannot use 'in' operator to search for 'x' in undefined`）

**现象**：`Popconfirm` 组件设计为可选透传 `okButtonProps`/
`cancelButtonProps` 给内部的 `<Button>`：
```tsrx
export interface PopconfirmProps {
    okButtonProps?: ButtonProps;
    cancelButtonProps?: ButtonProps;
}
export function Popconfirm(&{ okButtonProps, cancelButtonProps, ... }: PopconfirmProps) @{
    <Button theme="solid" ... {...okButtonProps}>{okText}</Button>
}
```
用户没有传 `okButtonProps` 时，`okButtonProps` 值是 `undefined`。这在
普通 JavaScript 里 `{...undefined}` 是完全合法的 no-op（等价于不展开
任何属性），但 Playwright 真机测试点击触发按钮时，浏览器控制台抛出
`TypeError: Cannot use 'in' operator to search for 'disabled' in
undefined`，堆栈直接指向 `Button` 组件解构 `disabled = false` 那一行
——Ripple 编译后的属性合并逻辑（`render_tsrx_element`）对 spread 进来
的 `undefined` 值做了 `'disabled' in props` 这类存在性检查，undefined
不是对象，`in` 操作符直接抛错，中断了整棵渲染树（触发按钮点击后浮层
完全不出现，且没有任何 console.error 能在页面上直接看到——只有真机
点击触发这条渲染路径时才会暴露，纯静态渲染或首屏加载完全不会命中）。

**规避方式**：任何要透传给子组件 JSX 的 `{...props}` 展开，其 props
若类型上是可选的（`?: SomeProps`），**必须在解构时给一个 `= {}` 默认
值**，不能依赖"JS spread undefined 是合法 no-op"这个原生语言行为：
```tsrx
okButtonProps = {},
cancelButtonProps = {},
```
函数参数解构的默认值兜底在 tsrx 编译产物层面同样生效、且是本仓库已有
组件的通用写法（对照 rest 参数 `...popoverProps` 天然不会是 undefined，
不受影响），只有"可选 prop 直接透传 spread"这一种模式需要特别注意。

**验证方法**：这类 bug 的报错完全发生在浏览器运行时（不是
typecheck/lint 能发现的），且只有真机点击触发对应渲染路径才会暴露，
`e2e` 测试点击交互失败时，第一时间用 Playwright 的 `--reporter=list`
输出（会带上 `[WebServer]` 前缀的浏览器 console 报错）而不是只看
测试断言失败信息本身——真正的根因往往在这些浏览器端日志里，而不是
表面的 "locator not found" 之类的断言错误。

## 踩坑 #49：Playwright `getByRole('button', { name: 'X' })` 默认非
精确匹配，新增组件演示按钮的文案若包含旧测试断言文本作为子串，会
让存量测试报"多义选择器"错误（踩坑 #46 的变体）

**现象**：playground 里新增了 `<Button>提交（异步回调，600ms）</Button>`
（Popconfirm 演示的一部分），存量的 `e2e/input/form.spec.ts` 里
`page.getByRole('button', { name: '提交' })`（未加 `exact: true`）
从"只命中 Form 演示区的提交按钮"变成同时命中这个新按钮——`'提交'`
是 `'提交（异步回调，600ms）'` 的前缀子串，Playwright 默认的
`name` 匹配是"包含"而非"完全相等"，触发严格模式报错。这和踩坑 #46
（新组件复用已有组件导致 aria-label 完全相同）是同一类问题的另一种
触发方式——**不需要 aria-label 完全相同，只要新文案包含旧断言的
匹配文本作为子串就会触发**，覆盖面比 #46 描述的更广。

**规避方式**：任何 e2e 测试里用 `getByRole(..., { name: 'X' })` 或
`getByText('X')` 做精确身份判断（而非"页面上存在含有 X 的东西"这种
弱校验）时，一律加 `exact: true`，不要依赖"这个文案在页面上唯一"
的假设——这个假设会随着后续组件增多持续被打破，`exact: true` 是
面向未来的防御写法，不是可选的代码风格偏好。

## 踩坑 #50：`throttle()` 只做 leading-edge（首次立即执行、窗口内后续
调用全部丢弃）会导致"窗口内最后一次调用的最终状态永远丢失"，快速
连续两次滚动场景下是真实功能 bug，不只是 e2e 测试时序偶发

**现象**：`BackTop` 组件用 `packages/foundation/src/base/animate-
value.ts` 的 `throttle(handleScroll, 100)` 监听滚动事件。e2e 测试
"滚动到 500px 后隐藏按钮出现，再滚动回 0px 后按钮重新隐藏"稳定失败——
`repeat-each=5` 跑 5 次全部在第二个断言（滚回 0px 后应该隐藏）失败，
按钮一直显示。排查发现两层问题：
1. **组件挂载时的初始化调用占用了节流窗口**：`effect()` 里 `const
   throttledHandleScroll = throttle(syncVisible, 100); ...
   throttledHandleScroll()` 把初始化同步也套进了节流函数，紧随其后
   的真实 `scroll` 事件如果在 100ms 内到达会被吞掉。**修复**：初始化
   调用用未节流的 `syncVisible()` 直接执行，节流只包装 `addEventListener`
   注册的那个监听器。
2. **修复第一层后仍然失败**：连续两次 `page.evaluate(() => window
   .scrollTo(...))`（先到 500 再到 0）间隔通常远小于 100ms 节流窗口，
   第二次滚动事件被节流跳过，而原实现是纯 leading-edge（`current -
   last >= ms` 才执行，否则直接丢弃，不做任何补偿），所以"滚动停止
   那一刻"的最终状态永远没有机会被同步——这不是测试时序问题，是
   `throttle()` 工具函数本身的设计缺陷：任何"高频事件+读最终状态"
   的消费场景（滚动位置、resize 尺寸等）都会踩到同一个坑。

**修复**：`throttle()` 改造成 leading + trailing 模式——窗口内被跳过
的调用记录下最新参数，安排一次窗口结束后的补偿调用（`setTimeout`），
确保最终状态总会被同步。函数签名新增可选的 `setTimeoutFn`/
`clearTimeoutFn` 注入参数（默认用全局 `setTimeout`/`clearTimeout`），
保持可脱离浏览器环境单测。

**验证方法**：**必须用 `--repeat-each=N`（N≥5）重复跑同一个 e2e 测试
确认稳定性**，单次通过不能说明时序类 bug 已修复——本次两次单独运行
都通过、`repeat-each=5` 才稳定复现失败。任何涉及节流/防抖/滚动监听的
组件，验收测试都应该用这个方式做稳定性抽查，而不是跑一次绿了就算数。

## 全局命令式 API 模式验证（Toast/Notification 的技术基础）：`track()`
不能在模块顶层使用，但 `mount()` + "组件内部创建状态 + 回调反向暴露
更新函数"的模式已验证可行

**背景**：Toast.info()/Notification.open() 这类全局命令式 API（不需要
先在 JSX 里声明 `<Toast/>`，直接调用函数就能让内容出现在页面上）在
Ripple 下如何实现，此前是未知数——本仓库没有任何先例，Semi(React)
版本靠 `ReactDOM.render` + `ref` 拿组件实例调用其方法，Ripple 的对应
能力（`mount()`）语义不完全相同，需要实测验证。

**关键发现一**：**`track()` 只能在"响应式上下文"内使用，不能在模块
顶层直接调用**——尝试在模块作用域写 `let &[state] = track([])`
（在任何组件函数体之外）会在 `typecheck` 阶段直接报错：`` `track`
can only be used within a reactive context, such as a component,
function or class that is used or created from a component ``。这
排除了"模块级创建 track() 状态，直接传给 mount() 的组件当 props，
外部再改这个模块级状态"这个最直观的设计——它在源头就不成立。

**关键发现二**：**`mount(component, options)` 返回一个 `unmount`
清理函数**（`packages/.../ripple/src/runtime/index-client.js` 里
`return () => { cleanup_events(); destroy_block(_root); }`），不需要
额外确认"Ripple 是否有 unmount API"这个此前的未知数——`mount()` 本身
就是。

**验证通过的可行方案**（已用最小 demo 在 playground 真机跑通，连续
多次调用、响应式持续生效）：
```tsrx
// 模块作用域：只持有普通变量，不持有 track() 状态
let mounted = false;
let unmountFn: (() => void) | null = null;
let pushUpdate: ((items: T[]) => void) | null = null;
let currentItems: T[] = [];

// 组件内部创建 track() 状态，通过一个 props 回调把"更新函数"反向注册
// 回模块作用域——这是 Ripple 版本对应 React `ref` 拿实例调用方法的
// 替代方案，语义上更贴合"细粒度响应式，追踪点在字段读取而非组件实例"
// 的心智模型。
function ListRoot(&{ registerController }: { registerController: (fn: (items: T[]) => void) => void }) {
    let &[items] = track<T[]>([]);
    registerController((next: T[]) => { items = next; });  // 挂载时立即同步执行（mount 是同步调用）
    return <div>@for (const item of items; key item.id) { ... }</div>;
}

function ensureMounted() {
    if (mounted) return;
    const container = document.createElement('div');
    document.body.appendChild(container);
    unmountFn = mount(ListRoot as any, {  // mount() 的 TS 类型约束 Component<Record<string,any>>，
        target: container,                // 自定义 props 形状需要 as any 绕过（运行时无影响）
        props: { registerController: (fn) => { pushUpdate = fn; } },
    });
    mounted = true;
}

export const Toast = {
    info: (opts) => {
        ensureMounted();
        currentItems = [...currentItems, opts];
        pushUpdate?.(currentItems);  // 驱动已挂载组件内部的 track() 状态更新
    },
    destroyAll: () => {
        unmountFn?.();
        mounted = false;
        pushUpdate = null;
        currentItems = [];
    },
};
```

**关键时序细节**：`mount()` 内部同步调用 `render_component` →
`fn(props)`，即 `registerController(fn)` 在 `mount()` 调用返回之前
就已经执行完毕，`ensureMounted()` 之后立即调用 `pushUpdate?.(...)`
是安全的，不需要额外等待。但**驱动的状态更新本身是异步生效的**（同
Ripple 一般响应式更新机制一致），真机验证/e2e 测试断言 DOM 变化前
需要等待一个 tick（真机验证用 `wait(0.3)` 量级即可，e2e 用 Playwright
的 `expect().toBeVisible()` 之类的自动重试断言，不要用同步断言）。

**Toast/Notification 正式开发时的落地建议**：`registerController`
这个模式名字可以按组件语义换成更贴切的（如 `onControllerReady`），
核心结构不变；`currentItems`（队列数组）的增删改逻辑应该走
`ToastListFoundation`/`NotificationListFoundation`（对齐调研报告的
Foundation 设计），`pushUpdate` 只是"把 Foundation 算出的新队列同步
给已挂载组件"这一层胶水，不要把队列管理逻辑写在这层胶水代码里。

## 踩坑 #51（重大）：`@for` 的 `index`/`key` 修饰符必须严格按
`index i; key expr` 顺序书写，写反成 `key expr; index i` 会产生
一长串误导性极强、完全不指向真实错误位置的级联编译错误

**现象**：`Toast` 组件的 `ToastListRoot` 内部写了
```tsrx
@for (const item of list; key item.id; index i) {
```
`pnpm typecheck` 报出 20+ 条错误，分布在文件的多个不同位置（`let &[list]
= track(...)` 那一行报 `',' expected`、`<style>` 标签内的普通 CSS 规则
报 `Unexpected token`、文件最后的 `}` 报 `Declaration or statement
expected`），错误信息与真实问题（`@for` 修饰符顺序）在语义和位置上
毫无关联，第一直觉完全被带偏——依次怀疑过具名接口类型、嵌套箭头函数
类型标注、`track<T[]>([])` 数组字面量语法、模块顶层 JSX（`const
DEFAULT_ICONS: Record<...> = { success: <Icon />, ... }` 这种写法
其实是有先例的，被误判为可疑点），逐一试错均未修复问题。

**排查方法**：`tsrx-tsc` 的错误定位机制不可靠时（错误分布在文件各处、
和直觉上的"最近改动"关联不上），**用 `sed` 截取文件前 N 行 + 手写一个
最简单的合法收尾（`</>` + `}`），二分定位到底哪一段内容触发了解析
失败**——本次证明这是唯一真正有效的方法，比"看报错信息猜测"快得多。
截到只剩函数签名和空 JSX 骨架时完全正常，逐段加回真实内容，加入
`@for (...; key item.id; index i)` 那一行的瞬间错误立即复现，从而
精确定位。

**根因**：`specs/references/ripple-llms.txt` 里的官方示例固定写成
`@for (const user of visibleUsers; index i; key user.id)`——**`index`
在前、`key` 在后**是唯一合法顺序，此前所有组件都只单独用 `key` 或
只单独用 `index`，本仓库从未出现过需要同时用两者的场景，直到 Toast
需要"`key` 做 id 追踪 + `index` 算层叠深度"才第一次撞上这个顺序要求，
而语言层面对顺序写反没有做任何有意义的错误提示。

**规避方式**：`@for` 需要同时用 `index`/`key` 时，死记顺序
`index i; key expr`，不要凭直觉按语义重要性排列。这个模式值得作为
新组件开发前的检查项之一，与文档铁律"函数体用 `@{...}`""顶层包一层
`<>...</>`"并列。

## 踩坑 #52（重大）：Foundation 层给"可注入定时器"设计默认实现时，
直接写 `{ setTimeout, clearTimeout }` 会丢失隐式 `this` 绑定，真机
调用时抛 `TypeError: Illegal invocation`——且这个 bug 在 Node 单测
环境完全测不出来，也可能被"演示代码恰好没触发对应分支"长期掩盖

**现象**：`Toast`/`Spin` 两个组件的 Foundation 都设计了"定时器可通过
构造参数注入，默认用全局 `setTimeout`/`clearTimeout`"的模式（保持
可脱离浏览器环境单测），写成：
```ts
const DEFAULT_TIMERS: XxxTimers = { setTimeout, clearTimeout };
```
`Toast` 组件 e2e 真机测试第一次点击触发按钮就抛错：
`TypeError: Illegal invocation`，堆栈精确指向 `this.timerImpl
.setTimeout(...)` 这一行。根因是**原生 `setTimeout`/`clearTimeout`
是 `window` 对象上的方法，其内部实现依赖调用时 `this === window`**
——`{ setTimeout, clearTimeout }` 这种对象字面量简写等价于
`{ setTimeout: window.setTimeout, clearTimeout: window.clearTimeout
}`，把函数引用从 `window` 上剥离后单独存放；后续通过
`this.timerImpl.setTimeout(fn, ms)` 调用时，函数内部的隐式 `this`
绑定的是 `this.timerImpl` 对象而非 `window`，浏览器原生实现检测到
`this` 不对就抛 `Illegal invocation`。

**为什么 `Spin` 组件的这个同款 bug 没有在它自己的 e2e 阶段被发现**：
playground 里 `Spin` 的演示代码从未传过 `delay` prop（默认 `delay=0`
分支直接跳过定时器逻辑，不会调用 `this.timers.setTimeout`），所以这
条崩溃路径此前从未被真机测试真正执行到，直到排查 `Toast` 的同款问题
时顺带复查了本仓库所有用到相同 `{ setTimeout, clearTimeout }` 简写
模式的地方才发现。**这类"分支覆盖不全导致的隐藏 bug"和踩坑 #40
（module server 同步/异步写法错误被前置崩溃"意外保护"）是同一类
教训——bug 存在与否和"是否被执行到"是两回事，新组件的验收测试必须
覆盖所有条件分支对应的 prop 组合，不能只测默认值路径。**

**规避方式**：Foundation 层任何"注入原生浏览器/Node 全局方法"的默认
实现，禁止用 `{ method1, method2 }` 对象简写直接解构挂载，必须用
箭头函数包一层，让调用点落在函数体内部（此时函数体内的裸调用
`setTimeout(fn, ms)` 是隐式全局调用，语义上等价于 `window.setTimeout
(fn, ms)`，`this` 绑定正确）：
```ts
const DEFAULT_TIMERS: XxxTimers = {
  setTimeout: (fn, ms) => setTimeout(fn, ms) as unknown as number,
  clearTimeout: (handle) => clearTimeout(handle),
};
```
本文档 `animate-value.ts` 的 `raf`/`cancelRaf` 默认值（`(cb) =>
requestAnimationFrame(cb)`）从一开始就用了这个正确写法，`Date.now`
之所以能直接解构赋值是因为它是不依赖 `this` 的纯静态方法——同一份
代码里"到底哪个全局方法能直接解构、哪个不能"没有统一规律，唯一
安全的默认做法是**一律用箭头函数包裹，不要因为"这个方法看起来简单"
就走捷径直接解构**。

## 踩坑 #53（重大，Ripple 运行时本身的 bug，非 lotus 代码问题）：
`@for` keyed 循环一次性在数组中间插入 ≥2 个新节点时，除第一个外全部
插错位置——根因是 `reconcile_by_key`/`reconcile_by_ref` 的纯插入
快速路径用新数组下标去索引老数组

**现象**：`Tree` 组件展开"前端组"节点（一次性插入"张三""李四"两个
新的叶子节点到"前端组"和"后端组"之间）时，DOM 实际渲染顺序变成
`研发部|前端组|张三|后端组|李四|产品部`——"李四"被错误地插到了"后端组"
之后。用纯 Node 脚本直接调用生成这份列表的纯函数 `flattenTreeData()`
（`packages/foundation/src/navigation/tree/tree-data.ts`）验证过，
纯函数本身返回的顺序完全正确；问题只在真机渲染层出现，且插入数量
为 1 时不会触发（这也是为什么此前的 Toast/Notification/BackTop 等
组件都没有撞见这个 bug——它们没有"一次性插入多个 keyed 节点到列表
中间"这个模式，Toast 的追加是"插入到末尾"、BackTop 是纯粹的显示/
隐藏而非列表增删）。

**根因**：`~/i/ripple`（`Ripple-TS/ripple`，lotus 通过
`catalog: ripple: 0.3.119` 固定版本依赖的独立第三方框架仓库）的
`packages/ripple/src/runtime/internal/client/for.js`，
`reconcile_by_key`（keyed diff）和 `reconcile_by_ref`（非 keyed
diff）两个函数里"双向 trim 后老数组已耗尽、纯插入新节点"的快速路径
（`j > a_end` 分支，约 480 行和 767 行）：
```js
if (j > a_end) {
  if (j <= b_end) {
    while (j <= b_end) {
      b_val = b[j];
      var target = block_start(a_blocks, j, a_length, anchor);  // bug：用新数组下标 j 索引老数组 a_blocks
      b_blocks[j] = create_item(target, b_val, j, render_fn, is_indexed, true);
      j++;
    }
  }
}
```
`block_start(blocks, index, length, fallback)` 语义是"从 `blocks[index]`
开始往后找第一个非空 DOM 起点"，参数里的 `blocks` 和 `index` 必须
是同一个数组空间的。这里传入的是**老数组** `a_blocks`，却用**新数组**
的循环下标 `j` 去索引它——两者语义完全不对齐。整批新节点应该统一
插入到同一个位置（老数组里"后缀 trim 后幸存下来的第一个块"，
即 `a_blocks[a_end + 1]`），但代码却让每次循环都用递增的 `j` 重新
计算一次错误的锚点：第一个新节点凑巧命中了正确位置（此时 `a_blocks[j]`
恰好等于 `a_blocks[a_end+1]`），后续每个新节点的锚点都往后错位一格。
文件里另一处相同模式的倒序插入分支（约 603/610/623 行）用的是
`block_start(b_blocks, next_pos, b_length, anchor)`——**新数组 `b_blocks`
+ 新索引**，这才是正确的组合，证明这是一处孤立的疏漏而非设计原则。

**修复**（已在 `~/i/ripple` 本地验证：132 个测试文件、1511 个测试
全部通过，新增回归测试 `for.test.tsrx`「keyed for inserts multiple
new items in the middle in correct order」在修复前失败、修复后
通过；分支 `fix/for-keyed-multi-insert-anchor` 已 push 到
`chenzylab/ripple` fork，尚未向上游提交 PR）：把锚点计算移到循环外，
用固定的 `a_end + 1` 而不是循环变量 `j`：
```js
if (j > a_end) {
  if (j <= b_end) {
    var insert_target = block_start(a_blocks, a_end + 1, a_length, anchor);
    while (j <= b_end) {
      b_val = b[j];
      b_blocks[j] = create_item(insert_target, b_val, j, render_fn, is_indexed, true);
      j++;
    }
  }
}
```
`reconcile_by_ref` 里的镜像代码同样修复。

**lotus 侧的落地**：用 `pnpm patch ripple` 生成 `patches/ripple.patch`，
`pnpm-workspace.yaml` 声明 `patchedDependencies: ripple: patches/
ripple.patch`——这样 `pnpm install` 会自动应用修复，不依赖手动改
`node_modules`（那种改法会被下一次 `pnpm install` 覆盖，之前验证
阶段踩过一次）。**任何组件如果出现"纯函数算法验证正确、但真机渲染
顺序错乱"且命中"一次性插入多个新 keyed 节点到列表中间"这个模式，
先怀疑这个 Ripple 运行时 bug，而不是先怀疑自己的 Foundation 算法或
`.tsrx` 组件代码**——本次排查一开始误判方向，以为是 `handleToggleExpand`
的 toggle 逻辑或点击事件绑定有问题，排查了很久才用"纯函数单独跑
+ 真机对比"的方法定位到问题只在渲染层，未来遇到类似现象应该优先
做这一步对比，能少走很多弯路。

## 踩坑 #54：本机同时开着多个不同项目的 Vite dev server 时，
`playwright.config.ts` 里的固定端口号可能撞上其他项目，导致
`reuseExistingServer` 误连别的项目页面，e2e 全部定位器返回 0 元素

**现象**：Tree 组件 e2e 测试全部失败，报错都是"locator resolved to
0 elements"——`[aria-label="单选 Tree"]` 这类精确的 aria-label
定位器理论上不该找不到元素。排查后发现 `playwright.config.ts` 固定
写死 `baseURL: 'http://localhost:5183'`，而当时 `5183` 端口被
另一个完全不相关的项目（`chenzy.design`）的 vite dev server 进程
占用了（本机日常会同时开多个项目的 dev server，5170-5260 这个号段
是各个项目最常用的默认/常用端口区间，很容易撞车）。本地默认
`reuseExistingServer: !process.env.CI`，Playwright 探测到端口已经
有服务在监听就直接复用，实际连上的是别的项目的页面，Tree 组件的
DOM 自然完全不存在。

**规避方式**：`playwright.config.ts` 的固定端口选用 `5170-5260`
这类常见开发端口号段之外的高位号段（本仓库改成了 `48213`），撞车
概率大幅降低。**不要尝试 kill 掉占用端口的陌生进程来"解决"这类
问题**——那个进程可能是用户在其他项目里正在进行的工作，贸然杀掉
是破坏性操作，应先用 `lsof -nP -iTCP:<port> -sTCP:LISTEN` 查清楚
进程属于哪个项目，再决定换端口还是询问用户。

## 踩坑 #55（重大）：同一父级里两个互斥的 `@if (cond) { {a} }
@if (!cond) { {b} }` 分支，各自只包一个 JSX 文本插值时，两个分支
都可能渲染成空——这是踩坑 #41（`@if/@else` 同 class 容器）的
变种，但触发条件更隐蔽：不需要 class 相同，甚至不需要在 `@for`
循环体内

**现象**：Badge 组件的数字/文字内容完全不渲染。写法是：
```tsrx
<span class={countClasses} ...>
    @if (!dot && custom) {
        {count}
    }
    @if (!dot && !custom) {
        {text}
    }
</span>
```
用 Foundation 纯函数单独验证过 `formatCount`/`isCustomContent` 的
返回值完全正确（`text: "5"`, `custom: false`），也用 `console.log`
在组件函数体内确认了这些响应式变量的实际取值也是对的；但真机渲染
出来的 `.lotus-badge-count` 内部 `innerHTML` 是 `"<!----><!---->"`
——两个 `@if` 分支都判定为空，尽管两个条件互斥、逻辑上必然有且
只有一个为真。

**根因**：未深挖到 Ripple 编译器/运行时的具体实现细节（不像踩坑
#51/#53 那样定位到源码行号），但现象和踩坑 #41、#47 是同一类
"多个 `@if`/`@else` 分支包裹简单 JSX 插值时的编译或响应式追踪
异常"，怀疑是同一族尚未被官方修复的边界问题。**这类坑的共同特征
是：换成单一分支 + 表达式求值就能规避**，说明问题出在"多分支
`@if` 结构本身的 DOM patch 逻辑"，而不是分支内表达式的求值时机。

**修复**：把两个互斥 `@if` 分支合并成一个 `track()` 派生值，用
单一 JSX 插值渲染：
```tsrx
let &[displayContent] = track<any>(() => (dot ? '' : custom ? count : text));
// ...
<span class={countClasses} ...>
    {displayContent}
</span>
```
修复后 `pnpm typecheck` 无报错、真机渲染内容完全正确。

**对后续组件开发的启示**：当"渲染结果为空但所有上游数据/纯函数
都已验证正确"时，**优先怀疑多分支 `@if`/`@else` 包裹简单插值这个
模式本身**，而不是继续下钻业务逻辑——本次排查一度怀疑过响应式
追踪、HMR 缓存（后者也确实存在，见下），如果一开始就先做"合并成
单一插值试一次"这个最小改动排除法，能省下大量排查时间。**任何
组件里出现"两个及以上 `@if` 分支各自只包一段简单文本/表达式插值"
的写法，都应该默认改写成三元表达式 + `track()` 派生值 + 单一
插值**，不要等到真机渲染为空才回头改。

**顺带发现的独立问题（同一次排查中，环境噪声）**：改代码后 HMR
可能不生效，浏览器仍在渲染旧版本组件——本次现象是"改了 aria-label
的挂载位置，但真机渲染出的还是修改前的值"。`pnpm dev` 后台运行时
偶发 `open terminal failed: not a terminal`（pnpm 自身的 TTY 检测
在 `nohup ... &` 场景下失败导致 dev server 直接没启动，而不是启动
后卡住），加 `CI=true` 环境变量前缀可以绕过。**每次怀疑"改了代码
但效果没变化"时，第一步永远是先确认 dev server 真的存活、真的是
最新代码在跑（必要时 `rm -rf node_modules/.vite` 全量重启 + 检查
启动日志里的实际监听端口），而不是继续在业务逻辑里找原因**——本次
和踩坑 #43/#44 是同一族"看似代码问题、实为本地开发环境状态不稳定"
的教训，环境负载高（本机同时跑多个项目的 dev server）时这类问题
出现频率会明显升高。

## 踩坑 #56：`<table>` 使用 `table-layout: fixed` 时，`<th>` 上常见的
"用 `width: 1px` + `white-space: nowrap` 让列宽由内容撑开"技巧完全
失效，导致相邻单元格文字重叠

**现象**：Descriptions 组件的 vertical/horizontal/plain/row 全部
布局模式，key 和 value 的文字视觉上重叠在一起（如"姓名"和"张三"叠
在同一位置），但 e2e 测试断言（`toContainText`）全部通过——因为
`innerText`/`textContent` 不受 CSS 布局影响，纯文本断言测不出视觉
重叠这类问题，必须真机截图或用 `boundingBox()` 检查元素几何位置
才能发现。

**根因**：CSS 里给 `<table>` 设置了 `table-layout: fixed`，同时给
`<th>` 设置了 `width: 1px`（意图是"key 列尽量窄，具体宽度由内容撑
开"，这是 `table-layout: auto` 模式下的常见技巧）。但 `fixed` 布局
模式下，浏览器会把 `width: 1px` 当作这一列的**真实固定宽度**（不
根据内容调整），导致 key 列被压缩到 1px，文字溢出到相邻单元格，
和 value 列的内容视觉重叠。这两个 CSS 属性单独看都没问题，组合在
一起才会出错——`fixed` 布局的设计初衷就是"列宽由声明值决定、不依赖
内容测量"，这与"用 `width:1px` 撑开列宽"的技巧的前提（内容决定宽度）
直接矛盾。

**修复**：改用 `table-layout: auto`（浏览器根据内容自动计算列宽），
保留 `<th>` 的 `width: 1px` + `white-space: nowrap` 组合（在 `auto`
模式下这个组合是有效的"最小宽度提示"写法，不会真的截断到 1px）。

**验收方法教训**：这次是靠真机截图肉眼发现的，之前写的 e2e 断言
（`toContainText`、`toHaveClass`）全部通过却完全没测出这个明显的
视觉 bug。**任何用 `<table>` 或多列 CSS 布局实现的组件，e2e 验收
除了内容/class 断言外，必须额外加一条用 `boundingBox()` 比较相邻
元素几何位置的测试**（如断言 `valueBox.x >= keyBox.x + keyBox.width`
确认不重叠），不能只依赖截图人工看一遍就心安——截图容易被跳过或
看得不够仔细，而几何断言能固化成回归防护，防止未来改动重新引入
同类问题。

## 踩坑 #57（重大）：`.tsrx` 文件内部写 `export { X, type Y } from
'./other.tsrx'` 这种混合 `type` 修饰符的 re-export 语法，`tsrx-tsc`
typecheck 完全测不出问题，但 Vite/rolldown 实际构建时直接解析失败

**现象**：Collapse 组件 `packages/ripple/src/show/collapse/index.tsrx`
末尾写了：
```ts
export {
    CollapsePanel,
    type CollapsePanelProps,
} from './panel.tsrx';
```
`pnpm typecheck`（`tsrx-tsc -p tsconfig.json --noEmit`）**完全没有报错**，
`pnpm lint` 也没有报错。但启动 `apps/playground` 的 Vite dev server 时，
依赖预打包阶段直接抛出解析错误：
```
[PARSE_ERROR] Expected `,` or `}` but found `Identifier`
  ╭─[ .../show/collapse/index.tsrx:106:30 ]
  │
106 │ export { CollapsePanel, type CollapsePanelProps } from './panel.tsrx';
  │        ┬                     ─────────┬────────
  │        ╰──────────────────────────────────────── Opened here
  │                                       │
  │                                       ╰────────── `,` or `}` expected
```
错误来自 rolldown（Vite 8 的底层打包引擎）的 SWC/oxc 解析器，说明
`.tsrx` 文件的编译管线在处理 `export {...} from` 这种 re-export 语法
时，对 `type` 修饰符的支持和 `tsrx-tsc` 的 TypeScript 类型检查器不
一致——这是**两条完全独立的解析路径**（typecheck 走 `tsrx-tsc`，
实际打包走 Vite 插件 + rolldown），其中一条能通过、另一条会硬崩，
必须两条都过才算真正验证完整。

**规避方式**：仓库里全部现存 re-export 都只出现在纯 `.ts` 文件
（如 `packages/ripple/src/index.ts`），从未在 `.tsrx` 文件内部转发
过其他文件的导出——这次是新模式第一次踩坑。修复：把 `CollapsePanel`
的导出直接挪到 `packages/ripple/src/index.ts`，让它各自独立地从
`./show/collapse/index.tsrx` 和 `./show/collapse/panel.tsrx` 分别
import，不在 `.tsrx` 文件内部做二次转发：
```ts
export { Collapse, type CollapseProps } from './show/collapse/index.tsrx';
export { CollapsePanel, type CollapsePanelProps } from './show/collapse/panel.tsrx';
```
**结论性规则：`.tsrx` 文件内部不要写 `export {...} from '...'` 这种
re-export 语句（无论有没有 `type` 修饰符），所有跨文件导出转发一律
放在 `.ts` 文件（通常是包的 `index.ts`）里做。** 这类"typecheck 过、
实际构建崩"的坑，`pnpm typecheck` + `pnpm lint` 双绿灯不能作为组件
开发完成的充分证据，新组件写完后第一次跑 dev server 启动 playground
本身就是一道独立的验收关卡，不能跳过（这也解释了为什么本仓库的
DoD 流程里"playground 真机验证"始终是typecheck/lint之后的独立步骤，
不是可选项）。

## 踩坑 #58：`@if (cond)` 里的 `cond` 如果是普通 `const` 变量（哪怕
它的计算依赖了响应式的 props），只在组件挂载时求值一次，`cond`
依赖的 prop 后续变化不会触发这个 `@if` 分支重新判定

**现象**：Collapsible 组件点击外部按钮切换 `isOpen` 后，`class`
属性（`isOpen ? 'lotus-collapsible-open' : ''`）正确响应式更新了，
但 `@if (shouldRenderChildren) { <div class="lotus-collapsible-inner">
{children}</div> }` 这个分支的内容却始终保持挂载时的初始状态——
`isOpen` 从 `false` 变成 `true` 后，`.lotus-collapsible-inner`
应该从"不存在"变成"存在"，但真机验证显示它一直不存在，`innerText()`
也始终是空字符串。

**根因**：`shouldRenderChildren` 写成了 `const shouldRenderChildren
= isOpen || keepDOM;`——这是一次性求值的裸 `const`，不是响应式
表达式。同一个组件里，写在 JSX **属性值位置**的内联表达式
（`class={isOpen ? 'a' : 'b'}`）能被 tsrx 编译器识别为需要响应式
追踪，但抽出成一个独立的 `const` 变量、再把这个变量名传给
`@if`/属性，就丢失了这层追踪——这与 Nav/SubNav 组件更早记录的
经验完全一致（"tsrx 编译器判定 JSX 属性/条件分支是否需要响应式
更新是纯语法层面的，裸 const 只在挂载时求值一次"），但这是这条
规则在 `@if` 条件表达式位置的第一次真实复现，此前的记录只覆盖了
JSX 属性值位置。

**修复**：把这类"要在 `@if`/JSX 属性里使用、且依赖 props 计算"
的中间变量一律用 `track()` 包裹：
```ts
let &[shouldRenderChildren] = track<boolean>(() => isOpen || keepDOM);
```
修复后真机验证展开/收起状态正确切换。

**结论性规则（扩展自 Nav/SubNav 的既有记录）**：**任何要参与响应式
渲染判定的中间计算值——不论是用在 `@if` 条件、`@for` 数据源、还是
JSX 属性值——只要它依赖了 props/其他响应式变量，就必须用 `track()`
包裹成 `let &[x] = track(() => ...)`，绝不能写成裸 `const x = ...`。**
唯一的例外是内联写在 JSX 属性值位置的表达式（`class={a ? 'x' : 'y'}`
这种直接字面量三元表达式），tsrx 编译器对这个特定位置有单独的响应式
识别逻辑；但凡是把计算过程抽出成一个命名变量，都必须显式 `track()`。
新组件写完任何 `const someFlag = propA || propB` 这类代码后，只要
`someFlag` 之后被用在 `@if`/`@for`/传给子组件的响应式渲染路径中，
默认当作有 bug 处理，除非能证明它确实是挂载时定值不需要响应式。

## 踩坑 #59（重大）：`track(() => ...)` 的 computed 求值函数内部
不能触发对其它 tracked 值的写操作（赋值），哪怕写操作发生在一个
看似普通的辅助函数调用里——Ripple 会直接抛运行时异常，不是静默
失效

**现象**：`ImagePreviewGroup` 组件里，`Image` 子组件需要在渲染时
向父级的 Context 注册自己的 `src`（拿到自己在多图列表里的序号），
最初写成：
```ts
const contextTracked = ImagePreviewGroupContext.get();
let &[groupIndex] = track<number | null>(() => (contextTracked ? contextTracked.value.register(src ?? '') : null));
```
`register` 函数内部会执行 `registeredSrcList = [...list, itemSrc]`
——这是对 `ImagePreviewGroup` 组件里另一个 tracked 值的写操作。真机
点击图片触发预览时，控制台直接抛出运行时异常：`Assignments or
updates to tracked values are not allowed during computed
"track(() => ...)" evaluation`，预览层完全打不开（`register`
调用链路中断，Context 状态没有正确建立）。这类 bug 和踩坑 #45/#58
类似——渲染时求值路径里混入了副作用，但这次是运行时**直接抛错**而
非静默返回旧值，说明 Ripple 对这条规则做了运行时校验，不是只有
"文档建议"层面的约定。

**根因**：`track(() => expr)` 的求值函数被设计为纯粹的"计算下一个
派生值"，Ripple 内部实现依赖这个纯度假设做依赖追踪/批量更新调度；
`register` 这个业务函数虽然从调用点看只是"读一下、拿个 index"，但
它内部隐藏了写操作，这种"看起来是读、实际有写副作用"的函数一旦被
装进 computed 求值路径，就违反了这个纯度约定。

**修复**：把有副作用的调用移出 `track()` 的 computed 函数，挪到
`effect()` 里执行（`effect` 允许产生副作用，这正是它存在的意义）：
```ts
let &[groupIndex] = track<number | null>(null);

effect(() => {
    if (!contextTracked) return;
    const index = contextTracked.value.register(src ?? '');
    untrack(() => { groupIndex = index; });
});
```
（内层用 `untrack()` 包裹对 `groupIndex` 自身的赋值，避免 effect
读写同一个值导致的死循环，同 Foundation 的 `untrack()` 铁律。）

**规避方式**：任何要放进 `track(() => ...)` computed 函数体的调用，
如果不能 100% 确定它是纯函数（尤其是跨组件通过 Context/props 传入
的回调、来自其它模块的工具函数），先假设它可能有副作用，宁可移到
`effect()` 里也不要图省事直接塞进 computed——这类 bug 在真机点击
交互前完全不会暴露（typecheck/lint 都测不出来，纯逻辑上"读一个值"
和"读的时候顺便写了别的值"在类型层面看不出区别）。

## 踩坑 #60：全屏预览层用 `flex` 居中布局的内层容器撑满了整个遮罩
区域时，`event.target === event.currentTarget` 判断"点击的是遮罩
空白处"会失效——只要遮罩上叠了任何撑满尺寸的子容器，这个判断就
永远为 false

**现象**：Image 组件的全屏预览层，点击遮罩空白区域（非图片、非
工具栏按钮）应该关闭预览，写法是最外层 `<div class="...-mask"
onClick={handleMaskClick}>`，`handleMaskClick` 判断
`event.target === event.currentTarget`。真机测试点击遮罩四角
（远离图片和工具栏的位置）预览层完全不关闭。

**根因**：遮罩内部紧跟着一个 `.lotus-image-preview-container`
（`display:flex; align-items:center; justify-content:center`，
没有显式限制宽高），这个容器实际撑满了整个遮罩区域（`width:100%;
height:100%` 是隐式的，因为没有设置任何尺寸限制，flex 子项默认
占满父级剩余空间）。点击遮罩上任意一点，`event.target` 拿到的都是
这个 container（或者更深层的图片元素），从不会是 mask 本身——
`target === currentTarget` 这个等值判断从设计上就不可能为真，因为
container 完全覆盖了 mask 的可点击区域，用户永远点不到"裸露"的
mask 像素。

**修复**：放弃 `target === currentTarget` 这种"点击的必须是最外层
容器自己"的严格判断，改成排除法——只要点击目标不是需要保留交互的
元素（这里只有图片本身需要排除，因为图片被拖拽时可能触发 click），
就视为点击了空白区域：
```ts
function handleMaskClick(event: MouseEvent) {
    if (!maskClosable) return;
    const target = event.target as HTMLElement;
    if (target.classList.contains('lotus-image-preview-img')) return;
    onClose?.();
}
```
工具栏按钮/左右切换箭头本身已经用 `event.stopPropagation()` 阻止
事件冒泡到 mask，不需要在这里额外排除。

**规避方式**：任何"点击遮罩关闭"的实现，只要遮罩内部有撑满尺寸的
中间容器（哪怕只是为了 flex 居中），`target === currentTarget`
这个经典写法就大概率是假阳性通过了 review 但实际不生效的坑——
真机点击测试遮罩的多个不同位置（不只测中心点，因为中心点常常被
内容本身覆盖，反而更容易在开发时被忽略），是唯一能发现这类问题的
方法，纯粹审代码看不出来。

## 踩坑 #61：`element.boundingBox()` 返回的是相对页面文档的绝对坐标，
`page.mouse.move(x, y)` 用的却是当前 viewport 视口坐标——不先
`scrollIntoViewIfNeeded()` 就把 `boundingBox()` 的结果直接传给
`mouse.move`，元素在页面下方时坐标系不匹配，事件会移动到错误位置
（甚至完全在可视区域外），导致悬浮/拖拽类交互测试静默失败

**现象**：Carousel 组件的"鼠标悬浮暂停自动播放"e2e 测试稳定失败——
`page.mouse.move(box.x + box.width/2, box.y + box.height/2)` 移动
后，组件的 `onMouseEnter` 处理器完全没有被调用（用临时 `console.log`
确认过，事件压根没触发）。playground 页面随着组件数量增多，Carousel
demo 区块在页面里的位置越来越靠下，`element.boundingBox()` 返回的
`y` 坐标（如 `10012.5`）早已超出测试用的 viewport 高度（`2000`）。
`page.mouse.move` 内部通过 CDP 直接按 viewport 坐标系发送鼠标事件，
如果目标坐标对应的浏览器窗口区域根本没有滚动到那里，实际移动到的
位置和期望元素完全对不上。

**规避方式**：任何用 `boundingBox()` 算出坐标后再喂给
`page.mouse.move`/`page.mouse.click` 等底层鼠标 API 的测试代码，
必须先对目标元素调用 `scrollIntoViewIfNeeded()`，确保视口已经
滚动到位、`boundingBox()` 返回的坐标落在当前可见区域内。这条规则
早在踩坑 #43 就记录过（"Playwright 拖拽测试需要
`scrollIntoViewIfNeeded()`"），但当时是偶发案例，这次是同类问题
的第二次独立复现——**任何直接操作绝对像素坐标的鼠标模拟
（`mouse.move`/`mouse.down`/`mouse.up`/`mouse.click(x,y)`），
一律先滚动到位**，应当成为写这类测试时的默认反射动作，而不是遇到
问题才回头补。相对而言，`locator.click()`/`locator.hover()` 这类
高层 API 会自动处理滚动，不受这条限制，只有直接算坐标传给
`page.mouse.*` 时才需要格外小心。

## 踩坑 #62：Image 预览层和 Carousel 都用了"下一张"/"上一张"/
"放大"/"缩小"/"旋转"这类通用中文 `aria-label` 文案，新组件上线后
存量测试的页面级裸选择器（`page.getByLabel(...)`）会命中多个同名
元素，触发 Playwright 严格模式报错——这是踩坑 #46/#49 的又一次
复现，且这次冲突的双方是完全不同的两个组件（不是同组件内部复用）

**现象**：Carousel 组件上线后，全量 e2e 回归里 Image 组件此前一直
通过的 `ImagePreviewGroup` 测试开始报错：`getByLabel('下一张')`
命中了 4 个元素——3 个 Carousel demo 实例的箭头按钮 + 1 个 Image
预览层的切换按钮，Playwright 严格模式拒绝在多义选择器上执行操作。

**规避方式**：Image 预览层的遮罩容器本身带 `role="dialog"`，用
`page.getByRole('dialog')` 先把定位范围限定到预览层内部，再在这个
scoped locator 上调用 `.getByLabel(...)`，即可精确排除页面上其他
同名元素：
```ts
const previewDialog = page.getByRole('dialog');
await previewDialog.getByLabel('下一张').click();
```
**结论性规则（在踩坑 #46 基础上进一步强化）**：`"下一张"`/`"上一张"`/
`"放大"`/`"缩小"`/`"关闭"`/`"确定"`/`"取消"` 这类高频通用交互文案，
**从组件设计阶段就应该假设它们迟早会在页面上出现多份**，e2e 测试
里只要涉及这类文案的 `getByLabel`/`getByRole('button', {name})`，
一律优先用容器（`role` 或 `aria-label` 唯一标识的外层元素）限定
scope，不要写页面级裸选择器——不能因为"当前只有一个"就心存侥幸，
下一个新组件随时可能引入同名交互元素。

## 踩坑 #63：e2e 测试断言依赖外部网络资源（跨域图片 URL）异步加载
完成的状态时，"元素可见"（`toBeVisible()`）不等于"资源已加载完成"
（如图片 `onLoad` 驱动的 opacity 状态），读取一次就断言存在偶发
失败的风险，外部资源加载耗时不可控

**现象**：Image 组件"加载成功后正确显示"这条 e2e 测试，读取
`getComputedStyle(el).opacity` 一次就断言等于 `'1'`，本地开发阶段
一直通过，但在全量回归里（并发更多、网络请求更密集时）偶发失败，
读到的是初始态 `opacity: 0`（图片资源还没真正下载完成，`onLoad`
事件还没触发，只是 DOM 元素本身已经挂载可见）。

**规避方式**：任何依赖外部资源异步加载完成态的断言，不能用
"等一下再读一次"这种一次性读取的写法，改用 `expect.poll(...)` 轮询
到目标状态出现为止，并给一个比默认超时更宽松的 timeout（外部网络
资源比本地渲染慢得多，不能套用本地交互的超时预期）：
```ts
await expect.poll(() =>
    image.locator('.lotus-image-img').evaluate((el) => getComputedStyle(el).opacity),
{ timeout: 10000 }).toBe('1');
```
这类"看起来稳定实际靠运气"的测试很危险——本地跑几次不会暴露，
只有在网络波动或并发压力增大时才会现出原形，新组件的 e2e 一旦
涉及外部资源加载，从写测试的第一天就要用轮询断言，不要等 CI 偶发
报警才回头修。

## 踩坑 #64（重大）：Foundation 状态机的 `state` 用 `track(() => initialState(prop))`
这种闭包形式声明时，闭包里读取的响应式 prop 会被 Ripple 判定为依赖，
prop 每次变化都会重新执行整个初始化函数、把 state 完全重置，导致状态
机形同虚设

**现象**：Modal 组件的显隐依赖一套独立于 `visible` prop 的状态机
（`displayNone` 只应该由 `handleShow()`/`handleAnimationEnd()` 两个
方法推进，用来实现"关闭动画播完才真正隐藏 DOM"）。声明写成
`let &[state] = track<ModalState>(() => initialModalState(visible));`——
这是一个 computed，闭包体读取了 `visible`。所以每次 `visible` 从
`true` 变为 `false`，这行 computed 会立刻重新求值，把 `state` 整个
替换成 `initialModalState(false)`（即 `{ displayNone: true, ... }`），
瞬间绕过动画状态机，`shouldRender` 立刻变 false，DOM 被瞬间拔除，
关闭动画根本没有播放机会，`onTransitionEnd`/`afterClose` 也永远不会
触发。这个 bug 极具迷惑性：真机测试如果只看"最终 Modal 有没有消失"，
现象和"正常工作"完全一致（DOM 确实消失了），只有专门监听
`transitionend` 事件、或者检查 `afterClose` 回调是否被调用，才能
发现动画状态机根本没有真正工作。

**规避方式**：任何"只应在挂载时取一次响应式 prop 的初值、后续完全由
Foundation 方法主动推进、不应该跟随该 prop 后续变化重置"的 state，
必须用 `untrack()` 包裹 prop 读取、且不能用闭包形式（闭包形式即使
内部包 `untrack()`，只要外层还是 `track(() => ...)`，Ripple 依然会
在依赖收集阶段扫描到闭包体内的响应式读取并建立依赖）：
```ts
// 错误：闭包体读取 visible，每次 visible 变化整个 state 被重置
let &[state] = track<ModalState>(() => initialModalState(visible));

// 正确：只读一次初值（untrack 防止建立响应式依赖），之后完全交给 Foundation 方法推进
let &[state] = track<ModalState>(initialModalState(untrack(() => visible)));
```
任何"内部持久状态机 + 外部驱动 prop"的组件（尤其是"显隐 + 关闭动画"
这类模式），验收时不能只用肉眼看"最终有没有消失/出现"，必须专门在
真机注入 `document.addEventListener('transitionend', ...)` 或检查
"动画结束回调是否真的被调用"来确认状态机真的按预期节奏推进，而不是
被响应式重置抄了近道。

## 踩坑 #65：CSS 用 `transition` 实现的动画，事件必须绑定 `onTransitionEnd`
而非 `onAnimationEnd`——后者只对 CSS `animation`（`@keyframes`）生效，
`transition` 属性永远不会触发它

**现象**：Modal 的关闭动画结束处理函数最初被绑定在遮罩层的
`onAnimationEnd` 事件上，但遮罩层 CSS 只写了
`transition: opacity 0.2s ease`（没有用 `@keyframes`/`animation`）。
`onAnimationEnd` 只对 CSS Animations API 触发，对 CSS Transitions
完全不生效，导致关闭动画结束后处理函数永远不会被调用。

**规避方式**：组件用哪种 CSS 机制做动画，就绑定对应的 DOM 事件——
`transition` 对应 `transitionend`（Ripple 里写作 `onTransitionEnd`），
`@keyframes`/`animation` 对应 `animationend`（`onAnimationEnd`）。
写完事件绑定后，直接搜索该元素的 CSS 规则确认用的是 `transition` 还
是 `animation` 关键字，两者绑错事件不会有任何编译期或运行时报错，
只会静默地永远不触发（现象与踩坑 #64 类似，都是"最终视觉效果看起来
正常但内部回调链路断裂"，真机验收同样需要专门监听目标 DOM 事件来
确认触发，不能只凭视觉判断）。

## 踩坑 #66（重大）：`keepDOM`/持久隐藏态元素只做 `opacity:0` 而不做
`display:none`（或不加 `pointer-events:none`），会变成一个不可见但
依然拦截全屏点击事件的"隐形玻璃罩"

**现象**：SideSheet 支持 `keepDOM` prop（关闭后内容不卸载，只是隐藏，
对齐 Semi 的设计）。`contentClasses`（内容区域）正确处理了这个逻辑
（`keepDOM && !visible` 时加 `lotus-side-sheet-hidden`，即
`display:none`），但 `maskClasses`（遮罩层）漏掉了同样的处理——遮罩
在 `keepDOM=true` 且从未打开过时，`visible=false` 只让它
`opacity: 0`，元素本身依然是 `position: fixed; inset: 0`（占满整个
视口）且没有 `display:none` 或 `pointer-events:none`。这个完全透明
但物理上占满全屏的元素会拦截页面上**所有**其它元素的点击——包括与
这个 SideSheet 毫无关系的其它按钮。真机测试和 Chrome
自动化工具的点击操作都会"看起来什么都没发生"，因为点击事件被这个
看不见的元素吞掉了，报错信息里唯一的线索是 Playwright 的
`intercepts pointer events` 日志（`await locator.click()` 重试超时
时打印的诊断信息），肉眼看截图完全看不出异常（因为遮罩透明）。

**规避方式**：任何"隐藏态但依然挂载在 DOM 里"的元素（`keepDOM`、
`v-show`/`display:none` 类模式），凡是可能占满较大区域（尤其是
`position: fixed` 全屏元素），隐藏时必须真正 `display:none` 或至少
`pointer-events: none`，不能只用 `opacity:0`。写这类组件时，只要
存在两个或以上的 CSS class（比如 mask + content）共同控制同一个
"隐藏态"语义，必须每一个都过一遍相同的隐藏逻辑，不能只改其中一个就
认为完成——这类遗漏在真机测试里极易被误判为"点击不生效是另一个功能
的 bug"（本次排查中曾先怀疑是 `transitionend` 事件绑定问题、Ripple
事件委托机制问题，兜了一大圈才定位到是这个遗漏），今后遇到"看似无关
的按钮突然点不动"，第一步就应该检查页面上是否有全屏 `position:fixed`
元素处于不可见但未真正禁用交互的状态（`document.elementFromPoint(x,y)`
或 Playwright 的 `intercepts pointer events` 报错是最快的定位方式）。

## 踩坑 #67（重大，Ripple 运行时本身的 bug，非 lotus 代码问题）：
多个 `Portal` 组件共享同一个 `target`（最常见就是 `document.body`）时，
任意一个 Portal 卸载都会把该 target 上共享的事件委托监听器整体拆除，
导致其它仍然挂载在同一 target 上的 Portal 彻底失去事件响应

**现象**：SideSheet 引入 `keepDOM` 场景后，出现一个极难定位的诡异
现象——"打开 Modal 再关闭它"这个动作之后，页面上任何**其它**通过
`<Portal target={document.body}>` 挂载的组件（不限于 SideSheet，包括
另一个 Modal 也会中招）只要是"从未真正走过挂载→卸载生命周期"的实例
（比如 `keepDOM=true` 从页面加载起就常驻挂载的 SideSheet），其内部
所有 `onClick` 绑定会突然全部失效——DOM 节点还在、位置正确、
`__click` 属性（Ripple 内部事件委托机制存 handler 引用的地方）里的
函数引用完好无损，用 `element.dispatchEvent(new MouseEvent('click'))`
主动派发也毫无反应，控制台没有任何报错。真机测试和 Chrome
自动化工具的点击操作全都"看起来点了但没有任何效果"。

**根因**：Ripple 用单一全局事件委托机制（`handle_root_events(target)`
在每个 `Portal` 挂载时调用一次，返回一个 cleanup 函数），但这个函数
对"同一个 `target` 被多次调用"的场景没有做引用计数——`Portal`
组件卸载/内容变化时执行自己的 cleanup，会无条件把 `target` 上的
`click`（及其它委托事件）监听器整体 `removeEventListener` 掉、并把
全局 `root_target` 置空，即使**其它 Portal 仍然共享同一个 target 并
依赖这个监听器**。这本质上是"最后一个卸载的 Portal 替所有共享同一
target 的 Portal 做了清理"，而不是"只清理自己贡献的部分"。

**排查路径**（供后续遇到类似"看似无关组件突然失去响应"时参考）：
1. 先排除 Chrome 自动化工具本身抽风（`tabs_context_mcp` 反复超时是
   信号，但真正的验证要脱离浏览器插件，改用独立的 Playwright 脚本
   在 headless 环境复现，脱离交互层的不确定性）。
2. 确认 DOM 节点、事件 handler 引用本身没丢（在 Modal/Ripple 里是
   `element['__click']` 这种约定属性，不是标准 `addEventListener`）。
3. 用最小复现二分定位触发条件（"是否必须先操作过某个无关组件"、
   "是否与组件类型有关还是与 Portal 挂载机制本身有关"）——本次是
   通过"Modal 开关一次 → keepDOM SideSheet 完全失去响应，即使 Modal
   和 SideSheet 类型完全不同"这个现象，判断出问题出在两者共享的
   底层机制（Portal + 事件委托），而非各自的组件逻辑。
4. 定位到框架层代码（`node_modules/.pnpm/ripple@.../events.js`
   `portal.js`）而非应用层组件代码时，直接去本地维护的 Ripple 源码
   仓库（`~/i/ripple`，与本仓库的 `patches/ripple.patch` 对应机制
   一致）修复，写回归测试验证 fix 前失败/fix 后通过，提交 PR
   到上游（这是本仓库第二次遇到 Ripple runtime 本身的 bug，第一次
   见踩坑 #53），并通过 `pnpm patch` 固化到本仓库直到上游发版合并。

**规避方式**：`handle_root_events` 已修复为按 `target` 引用计数
（`Map<Element, { count, registered_events }>`），只有当共享同一
target 的所有 Portal 调用方都释放完毕，才真正 `removeEventListener`。
这个修复已提交 Ripple 上游（PR #1434）并通过 `pnpm patch` 固化到
`patches/ripple@0.3.123.patch`。任何组件只要用到 `<Portal target=...>`
且 target 可能与其它组件共享（`document.body` 是最典型场景，几乎
所有全局浮层组件——Modal/Drawer/SideSheet/Toast/Notification——都会
用它），新增这类组件后必须补一条"另一个也用 Portal 挂载到同一
target 的组件开关一次，不影响本组件正常工作"的回归测试，不能只测
组件自己孤立存在时的行为。

## 踩坑 #68（重大）：单个 `.tsrx` 文件内定义多个组件函数（一个主组件 + 若干
非导出的辅助子组件函数）时，`.lotus-xxx` class 的 CSS 规则必须在**实际渲染
该 class 元素的那个组件函数自己的 `<style>` 标签里**定义，写在另一个组件的
`<style>` 里即使 class 名字符串完全相同也不会生效——Ripple 的 CSS 是按
组件函数作用域隔离的（scoped，class 名会被加上类似 `tsrx-XXXXXXXX` 的 hash
后缀，不同组件函数各自的 hash 不同）

**现象**：Calendar 组件为了拆分 week/month 两种视图的渲染逻辑，在同一个
`index.tsrx` 文件里定义了 5 个组件函数（`Calendar` 主组件 + `CalendarWeekView`
+ `CalendarDayEvents` + `CalendarMonthView` + `CalendarMonthWeekRow`，写法
参照踩坑列表里 Nav/Steps/Breadcrumb 的先例，非导出辅助组件用
`function XxxName(&{...}: Props) @{ ... }`）。`.lotus-calendar-event`（事件
条的背景色/圆角/内边距等基础样式）最初只写在 `CalendarWeekView` 的
`<style>` 标签里，但真正渲染带这个 class 的 DOM 元素的是 `CalendarDayEvents`
（分钟级事件）和 `CalendarMonthWeekRow`（月视图横条事件）这两个**不同的
组件函数**。结果：事件条的背景色完全透明（`getComputedStyle` 读出
`rgba(0,0,0,0)`），DOM 结构、`top`/`height`/`left`/`width` 内联定位样式全部
正确，只有这条基础外观规则完全不生效。真机截图看起来是"事件完全不可见"，
容易被误判为定位算法错误或渲染没有触发，实际上定位和渲染都是对的，只是
"看不见"因为背景透明、没有圆角边界。`.lotus-calendar-weekend`（周末列背景
高亮）也是同一根因：只写在 `CalendarWeekView` 里，`CalendarMonthWeekRow`
自己也用了这个 class 却没有对应规则，月视图周末列完全没有视觉区分。

**规避方式**：单文件多组件模式下，写完 JSX 里的某个 `class="lotus-xxx"`
或动态 class 数组后，第一反应应该是"这个 class 对应的 CSS 规则我加在了
哪个组件的 `<style>` 里，和当前正在写的这个组件是同一个函数吗"——不是
"这个 class 名字之前是不是已经定义过"（字符串层面存在 ≠ 作用域层面生效）。
CSS **后代选择器**（如 `.lotus-calendar-day-events .lotus-calendar-event`）
在"父子元素同属一个组件函数渲染的 DOM 子树"时依然有效，不受这条限制；
真正需要警惕的是"class 单独作为顶层选择器、渲染该 class 元素的却是另一个
组件函数"这种情况。这类 bug 编译期、typecheck、lint 全部测不出来，
Playwright 的文本内容/DOM 结构断言（`toBeVisible()`/`textContent`）也测不
出来（元素确实存在、确实可见、只是没颜色/没背景），必须用
`getComputedStyle()` 读实际计算值或真机截图肉眼比对才能发现——新组件如果
采用单文件多组件拆分，验收时不能只看 typecheck/lint 绿灯，必须对每个
被拆分出去的子组件单独截图确认视觉样式（不只是最外层容器）。

## 踩坑 #69（重大）：`ref={(node) => fn(node)}` 这种**箭头函数包裹**的写法，
函数体内部创建的资源（如 `ResizeObserver`）无法在元素卸载时自动清理——
Ripple 只有当 `ref` 直接是一个具名函数引用、且该函数返回一个清理函数时，
才会在卸载时调用这个清理函数；包一层箭头函数会导致返回值被丢弃

**现象**：OverflowList 组件的测量阶段，每个待测量的 item 用
`ref={(node) => handleItemRef(key, node)}` 绑定，`handleItemRef` 内部
`new ResizeObserver(...).observe(node)`。测量完成后组件从"测量态"切换到
"正式态"（`@if (allMeasured)` 切换渲染分支），测量阶段的 DOM 元素被卸载，
但对应的 `ResizeObserver` 从未 `disconnect()`。更严重的是，元素被移出
DOM 时浏览器给这个仍然存活的 observer 触发了一次"宽度变为 0"的回调，
这个回调依然被处理并写回了 `itemSizes` 这个 Map，把已经测量好的正确
宽度**覆盖成了 0**。所有 item 宽度归零后，"逐项累加是否超出容器宽度"
的算法自然判定"全部都能放下"，导致折叠功能完全失效——所有 item 无论
容器多窄都会被判定为"可见"，且现象具有强迷惑性：DOM 结构、CSS
（踩坑 #68 那次的教训）都排查了一遍无果，最终是靠打印 `layoutOverflowList`
的实际入参才发现 `itemSizes` 数组值不断被"从有效值变回全 0 再重新填充"，
才追查到是 observer 泄漏导致的脏写。副作用之一是触发浏览器原生
`ResizeObserver loop completed with undelivered notifications` 警告
（大量僵尸 observer 堆积导致同一帧内通知处理不完）。

**根因**（对照 Ripple 运行时 `blocks.js` 的 `ref()` 函数实现）：`ref` 属性
如果拿到的值 `typeof ref_value === 'function'`，会用
`effect(() => ref_value(element))` 包裹执行——**只有当这个 effect 函数体
的返回值本身是一个清理函数，元素卸载时才会调用它**。若像
`ref={(node) => handleXxxRef(key, node)}` 这样包一层箭头函数，箭头函数
体是一条表达式语句（没有 `return`），`handleXxxRef` 即使自己
`return () => observer.disconnect()`，这个返回值也会被外层箭头函数
丢弃——`effect()` 收到的返回值永远是 `undefined`，没有清理函数可调用。

**规避方式**：
1. 需要清理逻辑的 `ref` 处理函数，写法上要么直接传具名函数引用
   （`ref={handleContainerRef}`，函数自己 `return () => cleanup()`），
   要么包一层箭头函数时**显式 `return`**：
   `ref={(node) => { return handleItemRef(key, node); }}`——不能用
   看似等价的表达式简写 `ref={(node) => handleItemRef(key, node)}`
   （在 JS 语义上这两种箭头函数写法返回值应该一致，但当箭头函数体是
   花括号块 `{ ... }` 时必须显式 `return`，单表达式简写 `=> expr` 才会
   自动返回——这里的坑是容易把"需要透传闭包参数所以写成箭头函数"和
   "该不该用块语句体"这两件事搞混，写块语句体时最容易漏掉 `return`）。
2. 任何 `ref` 回调内部创建了需要显式释放的资源（`ResizeObserver`/
   `IntersectionObserver`/`MutationObserver`/`addEventListener` 等），
   都要返回对应的清理函数，并且要专门测试"资源是否在元素卸载后被正确
   清理"，不能只测"功能表现是否正确"（本次的 bug 甚至一度让功能"看起来
   正确"——宽区间容器场景不触发折叠，所以没暴露問題，只有窄容器强制
   折叠场景才会命中这条脏写路径）。
3. 排查"计算结果不符合预期但输入看起来合理"类问题时，不要只检查最终
   DOM，要打印计算函数的实际入参值——本次经验是"以为容器宽度或者算法
   本身有问题，实际是上游写入的原始测量数据本身被污染了"，误判方向会
   耗费大量排查时间。

## 踩坑 #70（重大）：flex 子项用 `flex:1` 试图从**没有固定高度的父级**分配空间，
若子项渲染内容的多少又反过来依赖对自身尺寸的响应式测量（`ResizeObserver`），
会形成"测量值→内容量→DOM尺寸→测量值"的正反馈几何级数增长，最终把整个浏览器
标签页拖死（不是抖动或性能问题，是真实的指数级失控）

**现象**：ScrollList 的 `cycled`（循环滚动）模式下，`ScrollItem` 会根据自身
测得的容器高度算出需要渲染多少组循环副本数据（副本越多，`<li>` 越多，内容
高度越大）。`.lotus-scroll-list-body`（容纳多列 `ScrollItem` 的横向 flex
容器）当初写成 `flex:1`，期望从父级 `.lotus-scroll-list`（`display:flex;
flex-direction:column`）分配到"剩余空间"，但 `.lotus-scroll-list` 本身
**没有设置任何 `height`**——`flex-grow:1` 在父级高度不确定（`auto`）时，
`flex-basis:auto` 会退化为参照内容的 intrinsic size 参与计算，而不是真正
"分配剩余空间"。于是：`ResizeObserver` 测出 `.lotus-scroll-list-body` 当前
高度 H → `ScrollItem` 据此算出需要渲染的循环副本数（副本数正比于 H）→
渲染出的 `<li>` 内容总高度约等于 `4H`（副本数 × 单项高度的乘积恰好放大 4
倍，这个倍数由 `calcCycledListLayout` 的 `ratio` 参数和单项高度共同决定）
→ 因为父级没有硬性高度约束，这个新内容高度直接变成 `.lotus-scroll-list-body`
的下一次测量值 → 循环重新开始，H 以约 4 倍/轮的速度指数增长（180→2592→
11232→45792→184032→736992...），几轮之内就会撑出几十万像素高的 DOM 树，
浏览器主线程被完全占满，连 `page.goto()` 的 `load` 事件、`page.evaluate()`
都无法响应，Playwright 只能报告整个 target 无响应并强制关闭连接。

**规避方式**：任何"子项内容量依赖对自身测量结果"的组件（这类"内容决定自己
下一步渲染量"的反身依赖，在虚拟滚动/循环列表/自适应折叠类组件里很常见，
本仓库 OverflowList 的踩坑 #69 也是同类根源的变体），驱动测量的那个 flex
容器必须有一条**不依赖内容、不参与 flex-grow 分配**的高度来源——要么是
显式的固定 `height`（不用 `flex:1`，而是让上层传入的高度值直接赋给它，
不参与父级的 flex 空间分配逻辑），要么整条父级链路上每一层都有真正确定的
高度（不能有任何一层是 `auto`）。排查这类"指数级失控"时的关键诊断手段：
给 `ResizeObserver` 回调加"熔断计数器"（超过 N 次后停止真正赋值但继续打印
诊断日志），观察连续几次测得的高度值序列，如果发现**稳定的倍数关系**（如
本例的约 4 倍/轮），几乎可以确定是"测量值反馈进内容量计算"的正反馈环，
而不是随机抖动或者布局性能问题——不要一开始就去查是不是浏览器 bug 或者
CSS 属性覆盖顺序问题，先用倍数关系的规律性快速定位到反馈环本身。

## 踩坑 #71：CSS `content-box`（默认）盒模型下，一个元素同时设置 `height:100%`
和显式 `padding`，浏览器计算出的 `clientHeight`（含 padding）会**大于**
`height:100%` 本身算出的值，`clientHeight = height + padding-top +
padding-bottom`——如果 JS 逻辑里用于坐标计算的"容器高度"变量，混用了这两个
不同语义的值（有的地方指 content 区域高度，有的地方指含 padding 的完整可视
高度），滚动定位计算会出现固定量级的坐标偏移

**现象**：ScrollList 的 `ScrollItem` 需要给列表首尾项留白（`padding-top`/
`padding-bottom`，让第一项/最后一项也能真正滚到视觉中心，这是对齐 Semi 用
`::before` 伪元素做留白的等价手法，这里改用了更直接的 `padding`）。最初
`<ul>` 写成 `height:100%; padding-top:Npx; padding-bottom:Npx`（`content-box`
默认盒模型），本意是让 `<ul>` 的可视高度等于外层容器高度、padding 只用于
制造额外的可滚动空间。但 `content-box` 下 `height:100%` 只决定 content
区域，`padding` 是在这之上**额外叠加**的，导致 `<ul>.clientHeight` 实际
变成 `外层高度 + 2*padding`（本例中 150px 外层高度、每侧 57px padding，
`clientHeight` 变成了 264px，不是预期的 150px）。JS 侧计算滚动目标位置
（`getScrollTopForIndex`）和吸附判定（`findNearestIndex`）用的却是"外层
150px"这个语义的高度参数，与浏览器实际使用的 264px 可视窗口不一致，导致
算出的目标 `scrollTop` 系统性偏离正确值——现象是"受控 `selectedIndex`
prop 变化后，滚动到的位置总是错开几项"，容易被误判为响应式更新没生效
（因为最终选中的确实不是期望的那一项，很容易先怀疑 prop 传递链路本身），
实际上 `effect` 的响应式追踪、prop 传递全部正确，纯粹是坐标系不一致这一
个几何计算问题。

**规避方式**：一个元素如果要"用 `height:100%`/固定 px 表达可视窗口大小"
同时还要"用 `padding` 制造滚动余量"，两者必须在同一个盒模型语义下统一：
要么显式 `box-sizing:border-box`（padding 被含在 height 内，此时 padding
会挤占 content 空间，若这不是期望效果则不适用），要么像本例最终采用的
方案——不依赖 `height:100%`，而是用 JS 显式计算 `element.style.height =
(外层高度 - 2*padding) + 'px'`，让 `content-box` 语义下"content 高度 +
padding = clientHeight"恰好等于外层高度。无论选哪种方案，JS 里任何读取
"容器高度"的地方，都要清楚这个数值到底是 content 区域高度还是含 padding
的 `clientHeight`，不能在计算链路的不同环节混用两种语义却不做换算——这
类偏移量通常是固定值（本例恒定 114px = 2×57px），若发现"滚动定位/吸附
命中总是稳定偏离预期几项、偏移量本身不随机变化"，应优先怀疑盒模型/坐标
系不一致，而不是逻辑分支写错。

## 对后续组件开发的结论性指导

- 所有涉及状态机的组件，Foundation 层一律继承 `packages/foundation/src/base/adapter.ts` 的 `Foundation<S>` 基类，不要重新发明 Adapter 接口形状。
- Adapter（`.tsrx`）侧的 `track()` + `new XxxFoundation({ getState, setState })` 三行样板代码可以直接复制本文档的范式，只需替换 State 类型和 Foundation 类名。
- 新组件开工前，先过一遍上面「已知踩坑」六条，尤其是 Fragment 包裹（#1）和 `tsrx-tsc`（#5）这两条——分别是最容易在编码阶段和 CI 配置阶段踩、且报错信息不直接指向根因的坑。
- **任何新包只要直接 import `.tsrx` 文件**（无论是组件包还是应用包），typecheck 脚本必须用 `tsrx-tsc` 而非 `tsc`，`package.json` 需要按上面 #5 的写法锁定 `typescript@5.9.3` 别名依赖 + `@tsrx/typescript-plugin` 依赖 + `tsconfig.json` 的 `plugins`/`jsxImportSource` 配置，四者缺一不可。
- **组件 props 解构一律用 `&{...}` 懒解构，不用普通 `{...}`**（踩坑 #30，重大）：`function Xxx(&{ a, b, ... }: Props) @{`。这是能否正确响应"外部驱动的受控 prop 变化"的前提，新组件从第一行就要写对；改造存量组件时顺手带上这个修复。
- **受控组件的验收测试必须包含"外部独立触发源驱动 prop 变化"场景**（踩坑 #30 的测试盲区教训）：不能只测"在组件自己的 DOM 节点上操作、验证自己更新"，要专门写一个不依赖该组件自身交互的外部按钮/状态源，驱动 `value`/`checked` 等受控 prop 变化，断言组件被动接收更新——这是受控组件契约的核心，之前全项目没有一个测试覆盖这个模式。
- **点击视觉隐藏的原生表单控件（`clip` 隐藏模式）时，e2e 测试要点它的可见父容器，不能点隐藏元素本身**（踩坑 #31）。
- **Foundation 需要"读旧值算新值"的增量运算时（集合增删等），`getState()` 受控模式下必须返回外部 prop 当前值，不能读永远过时的内部 state 快照**（踩坑 #32）。
- **Foundation 并发写多个字段时（`Promise.all` 场景），spread 合并的旧值读取必须紧贴写回前，不能用函数开局的快照**（踩坑 #34）。
- **多字段容器的 `reset()` 必须恢复到挂载时的完整初始快照，不能只恢复"曾经显式声明过初值"的字段子集**（踩坑 #35）。
- **`isControlled` 判断必须响应式，且身份切换后组件内部 state 不能残留陈旧值——用 effect 把外部受控值同步进 state，且 effect 内部读写同一 state 要用 untrack 避免死循环**（踩坑 #36，重大）。
- **Ripple 没有 render-prop 机制，"父组件注入渲染逻辑"类 API 要设计成"组件作为显式 prop + `<Comp {...} />` 渲染"，不能用 `children` 当函数调用**（踩坑 #37）。
- **Foundation 需要文案时通过方法参数注入（不反向依赖 `@lotus/locale`），且任何"从 locale 文案计算并缓存的结果"在 locale 切换后都需要主动重算，不会自动更新**（踩坑 #38）。
- **`apps/docs/ripple.config.ts`/`routes.ts` 不能从 `@ripple-ts/vite-plugin` 值 import `defineConfig`，但 `RenderRoute` 类值 import 是必需的、不能替换成 plain object**（踩坑 #39，重大）：`defineConfig` 用本地恒等函数 + `import type` 代替（避免 `process.platform` 崩溃），`RenderRoute` 保留原样（替换成 plain object 会破坏 `module server` 的 RPC handler 注册）。
- **`module server` 声明的数据获取函数在客户端是异步 RPC 调用，页面组件必须用 `async function` + `trackAsync` + `@try`/`@pending` 异步边界，不能写成同步 `const doc = loadDoc();`**（踩坑 #40，重大）：`trackAsync` 的声明和读取必须在同一个 `@try {}` 块的最外层直接语句里，不能拆到内层子组件。新增任何用到 `module server` 的 docs 页面时直接套用这个模式，且验收测试必须真机点击测试交互（不能只看页面渲染出了 HTML）。
- **`@if (cond) {...} @else {...}` 两分支渲染同 class 容器元素时 `@else` 分支内容可能不显示**（踩坑 #41）：改成两个条件互斥的独立 `@if` 块规避。验收测试必须真机检查渲染出的 DOM 内部内容（用 `outerHTML`/子元素断言），不能只看外层容器是否存在。
- **`var(--lotus-xxx)` 引用不存在的 token 名不会报任何编译错误，浏览器静默 fallback，页面照常渲染**（踩坑 #42）：新写的每个 `var()` 引用都要 grep `packages/tokens/dist/tokens.css` 核对键名真实存在，不能凭记忆/语义联想拼写；真机验收要用 `getComputedStyle()` 读实际计算值比对，不能只看元素是否可见。
- **高频连续保存代码时，`ego-browser` 复用的浏览器 tab 可能停留在陈旧 HMR 状态，表现和真实渲染 bug 完全一样**（踩坑 #43）：怀疑"改代码但效果不变"时先用 `curl` 对比 Vite 源码接口内容确认非服务端缓存问题，仍不对就直接重启 dev server + 换全新任务空间/tab 重新验证，不要在旧环境里死磕二分排查。**Playwright 拖拽类测试**在取 `boundingBox()` 前必须先 `scrollIntoViewIfNeeded()`，否则坐标可能与鼠标实际落点错位导致 `mousedown` 落空。
- **import 一个不存在的 `.tsrx` 文件会让 Vite dev server 静默卡死在启动阶段（不报错、不 ready、`curl` 返回 `000`）**（踩坑 #44，重大）：临时移动/删除某个正被 import 的目录做隔离排查时，必须同步注释掉对应的 import/export 语句。`curl` 返回 `000` 是"dev server 没真正启动完成"的强信号，应优先检查最近改动是否有悬空 import，而非怀疑组件渲染逻辑；`git stash` 比手动逐行注释更快定位这类环境级异常。
- **Foundation 适配器的 `setState` 实现里 `{ ...state, ...patch }` 展开同样需要 `untrack()` 包裹，不只是 `getState`**（踩坑 #45，重大）：遗漏时首次渲染完全正常，只有 prop 变化触发 `effect()` 重新执行、`setState` 被调用时才会因"同一 effect 读写同一 state"抛 `Maximum update depth exceeded`（与踩坑 #36 同根同源，触发点不同）。新组件必须有"外部按钮驱动 prop 变化后断言响应式更新"的 e2e 测试，这类测试天然会暴露此类死循环，纯首次渲染测试无法覆盖。
- **新组件内部复用已有组件时，可能让存量 e2e 测试的泛化选择器意外命中新增实例**（踩坑 #46）：e2e 测试优先用具体 aria-label/文本定位，通用 label（"关闭"/"确定"等）要追加区分性 class 组合限定范围；每个新组件开发完成后必须跑一次全量 `pnpm test:e2e`，不能只跑该组件自己的测试文件。
- **`@for` 循环体内直接放多个互斥 `@if` 分支（不包 `<>...</>`）会报 "renders a single node" 编译错误**（踩坑 #47）：循环体内容有条件分支时整体包一层 fragment；循环体是单一固定结构时不受影响。
- **可选 props 直接 `{...spread}` 透传给子组件 JSX 时，值为 `undefined` 会让 Ripple 运行时抛 `Cannot use 'in' operator ... in undefined` 崩溃整棵渲染树**（踩坑 #48，重大）：解构时必须给 `= {}` 默认值，不能依赖 JS 原生"spread undefined 是 no-op"的行为。这类 bug 只在真机点击触发对应渲染路径时暴露，排查时优先看 Playwright `[WebServer]` 前缀的浏览器 console 报错，而非只看断言失败信息。
- **`getByRole(..., { name: 'X' })` 默认非精确匹配，新组件演示文案若包含旧测试断言文本作为子串会让存量测试报多义选择器错误**（踩坑 #49，踩坑 #46 的变体）：用于身份判断的选择器一律加 `exact: true`，不要假设某段文案在整个 playground 页面里唯一。此规律在 TreeSelect 组件再次复现——"TreeSelect 受控示例"这个 `aria-label` 把已有的"Select 受控示例"整体包含为子串，导致 Select 那条存量测试（当初漏加 `exact: true`）在新组件上线后突然报多义选择器错误。**组件命名越接近（TreeSelect vs Select、Cropper vs Crop 之类），越容易撞车**——新增一个和已有组件名字有包含关系的组件时，除了给新组件自己的选择器加 `exact: true`，还要顺手 grep 一遍旧组件名的既有 `getByLabel`/`getByRole` 用法，补齐遗漏的 `exact: true`，不能只保证新代码这一侧写对。
- **`throttle()` 若只做 leading-edge（不补偿窗口内被跳过的最后一次调用）会丢失"事件停止那一刻"的最终状态**（踩坑 #50，重大）：改造成 leading+trailing 模式；任何涉及节流/防抖的组件，e2e 验收要用 `--repeat-each=5` 重复跑确认稳定性，单次通过不代表时序类 bug 已修复。
- **`@for` 同时使用 `index`/`key` 修饰符时顺序写反（`key expr; index i`）会产生一长串完全不指向真实错误位置的级联编译错误**（踩坑 #51，重大）：正确顺序固定是 `index i; key expr`。这类"错误信息与真实问题无关"的编译失败，用 `sed` 截取文件前 N 行 + 手写最简合法收尾做二分定位，比逐条猜测报错含义快得多。
- **Foundation 层给定时器等原生方法设计默认实现时，`{ setTimeout, clearTimeout }` 对象简写会丢失隐式 `this` 绑定，真机调用抛 `Illegal invocation`**（踩坑 #52，重大）：必须用箭头函数包裹（`(fn, ms) => setTimeout(fn, ms)`）。这类 bug 在 Node 单测环境测不出来，也可能因为"演示代码未触发对应分支"被长期掩盖——新组件验收要覆盖全部条件分支对应的 prop 组合，不能只测默认值路径。
- **`@for` keyed 循环一次性插入 ≥2 个新节点到列表中间时会插错位置，这是 Ripple 运行时本身的 bug（`for.js` 的 `block_start(a_blocks, j, ...)` 用新数组下标索引老数组），不是 lotus 组件代码的问题**（踩坑 #53，重大）：已在 `~/i/ripple` 修复并本地验证（132 测试文件全绿），lotus 用 `pnpm patch` 固化到 `patches/ripple.patch`。任何组件出现"纯函数算法验证正确、但真机渲染顺序错乱"且命中"一次性插入多个新 keyed 节点到列表中间"这个模式，先用"纯函数单独跑 + 真机 DOM 顺序对比"定位是渲染层还是算法层问题，不要一开始就扎进组件自己的事件/状态逻辑排查。
- **本机同时开多个项目的 dev server 时，`playwright.config.ts` 固定端口号可能撞上其他项目，导致 e2e 全部定位器返回 0 元素**（踩坑 #54）：端口选高位号段（如 `48213`）避开 `5170-5260` 这个各项目常用的默认端口区间；发现端口冲突时用 `lsof -nP -iTCP:<port> -sTCP:LISTEN` 查清楚是谁的进程，不要贸然 kill 陌生进程。
- **`<table>` 用 `table-layout: fixed` 时，`<th>` 上"`width:1px` 让列宽由内容撑开"的技巧完全失效，会导致相邻单元格文字重叠**（踩坑 #56）：改用 `table-layout: auto`。这类视觉重叠 bug 纯文本断言（`toContainText`）测不出来，用 `<table>` 或多列布局实现的组件，e2e 必须额外加 `boundingBox()` 几何位置断言，不能只靠人工看截图。
- **`.tsrx` 文件内部写 `export { X, type Y } from '...'` 这种 re-export 语法，`tsrx-tsc` typecheck 完全测不出问题，但 Vite/rolldown 实际构建时直接解析失败**（踩坑 #57，重大）：typecheck 和实际打包是两条独立解析路径。跨文件导出转发一律放在 `.ts` 文件（包的 `index.ts`）里做，`.tsrx` 文件内部不要写 re-export 语句。`pnpm typecheck` + `pnpm lint` 双绿灯不是组件完成的充分证据，第一次跑 dev server 是独立且必要的验收关卡。
- **参与 `@if`/`@for`/响应式渲染判定的中间变量若写成裸 `const`（哪怕依赖了响应式 props），只在挂载时求值一次，后续 props 变化不触发重新判定**（踩坑 #58）：一律用 `track(() => ...)` 包裹，唯一例外是内联写在 JSX 属性值位置的字面量表达式。任何 `const someFlag = propA || propB` 之后用于响应式渲染路径的写法，默认当 bug 处理。
- **`track(() => ...)` 的 computed 求值函数内部不能触发对其它 tracked 值的写操作，哪怕写操作藏在一个看似普通的辅助函数里，Ripple 会直接抛运行时异常**（踩坑 #59，重大）：任何要放进 computed 的调用，不能 100% 确定是纯函数就假设有副作用，移到 `effect()` 里执行（内层用 `untrack()` 包裹自身赋值防止死循环）。
- **全屏遮罩层内部若有撑满尺寸的 flex 居中子容器，`event.target === event.currentTarget` 判断"点击了遮罩空白处"会永远为 false**（踩坑 #60）：改用排除法（"点击目标不是需要保留交互的元素就视为空白"），并且真机测试要点遮罩的多个不同位置，不能只点中心点。
- **`page.mouse.move/click(x,y)` 用 viewport 坐标系，`boundingBox()` 返回的是页面绝对坐标，不先 `scrollIntoViewIfNeeded()` 会移动到错误位置甚至可视区域外**（踩坑 #61）：任何直接算坐标传给 `page.mouse.*` 的测试代码，一律先滚动到位；`locator.click()`/`locator.hover()` 这类高层 API 会自动处理，不受此限制。
- **高频通用交互文案（"下一张"/"放大"/"关闭"等）迟早会在页面上出现多份，新组件一旦引入同名元素就会让存量测试的裸 `getByLabel` 命中多义选择器报错**（踩坑 #62，#46 同族）：用容器 role/aria-label 限定 scope（如 `page.getByRole('dialog').getByLabel(...)`），不要写页面级裸选择器。
- **依赖外部资源异步加载完成态的断言（如图片 onLoad 驱动的 opacity），一次性读取会有偶发失败风险**（踩坑 #63）：改用 `expect.poll(...)` 轮询，给比本地交互更宽松的 timeout。
- **两个互斥 `@if` 分支各自只包一段简单 JSX 插值时，可能两个分支都渲染成空**（踩坑 #55，重大，与 #41/#47 同族）：合并成单一 `track()` 派生值 + 三元表达式 + 单一插值即可规避。当"渲染为空但上游数据/纯函数已验证正确"时，优先怀疑这个模式而不是继续下钻业务逻辑。同一次排查中还发现 `pnpm dev` 在 `nohup ... &` 场景下偶发因 TTY 检测失败而没启动（报 `open terminal failed: not a terminal`），加 `CI=true` 前缀绕过；改代码后"效果没变化"要先确认 dev server 真的存活、真的是最新代码在跑，不要在业务逻辑里继续找原因。
- **持久状态机的 `state` 用 `track(() => initialState(prop))` 闭包形式声明，闭包体读取的响应式 prop 会建立依赖，prop 每次变化都会把整个 state 重置**（踩坑 #64，重大）：改用 `track(initialState(untrack(() => prop)))`（非闭包 + `untrack`）只读一次初值，后续完全交给 Foundation 方法推进。这类 bug 现象和"正常工作"几乎一致（最终状态看起来对），验收必须专门确认状态机中间过程按预期节奏推进（如监听 `transitionend`、检查回调是否真被调用），不能只看最终结果。
- **CSS 用 `transition` 做动画时绑定 `onAnimationEnd`（只对 `animation`/`@keyframes` 生效）不会触发**（踩坑 #65，与 #64 同族）：`transition` 对应 `onTransitionEnd`，`animation` 对应 `onAnimationEnd`，写完直接核对该元素 CSS 用的是哪个关键字。两者绑错不会有任何编译期/运行时报错，只会静默永远不触发。
- **`keepDOM`/隐藏态元素只做 `opacity:0` 不做 `display:none`/`pointer-events:none`，会变成拦截全屏点击的隐形玻璃罩**（踩坑 #66，重大）：同一"隐藏态"语义如果由多个 class（mask + content）共同控制，每一个都要过一遍隐藏逻辑，不能只改一个。"看似无关的按钮突然点不动"时先查页面上是否有全屏 `position:fixed` 元素隐身但未禁用交互。
- **多个 `Portal` 共享同一 `target`（如 `document.body`）时，任意一个卸载会把共享的事件委托监听器整体拆除，导致其它仍挂载的 Portal 彻底失去响应**（踩坑 #67，重大，Ripple runtime 本身的 bug）：已在 `~/i/ripple` 修复（`handle_root_events` 按 target 引用计数）并提交上游 PR #1434，本仓库用 `pnpm patch` 固化到 `patches/ripple@0.3.123.patch`。任何用 `<Portal target={document.body}>` 的新组件，必须补一条"另一个同样用 Portal 挂载到同一 target 的组件开关一次不影响本组件"的回归测试。
- **单文件多组件模式下，`.lotus-xxx` class 的 CSS 规则必须写在实际渲染该 class 元素的那个组件函数自己的 `<style>` 里，写在另一个组件的 `<style>` 里即使 class 名相同也不生效**（踩坑 #68，重大，Ripple scoped CSS 按组件函数隔离）：typecheck/lint/DOM 结构断言全部测不出来（元素存在、可见，只是没样式），必须 `getComputedStyle()` 或真机截图逐个子组件核对。写完某处 `class="lotus-xxx"` 时第一反应是"这条规则我加在了哪个组件的 `<style>` 里，和当前组件是同一个函数吗"。
- **`ref={(node) => fn(node)}` 这种箭头函数包裹写法，`fn` 内部返回的清理函数会被丢弃，元素卸载时不会执行**（踩坑 #69，重大）：Ripple 只在 `ref` 直接是具名函数引用（或箭头函数体显式 `return`）时才会用其返回值作为卸载清理逻辑；`ref` 回调内创建的 `ResizeObserver`/`IntersectionObserver`/事件监听器等资源必须验证"元素卸载后是否真的被清理"，不能只测功能表现——本次教训是资源泄漏导致卸载元素的最后一次尺寸回调（宽度归零）脏写覆盖了有效测量数据，现象却表现为"算法判断错误"，排查时应打印计算函数实际入参而非只检查最终 DOM/CSS。
- **flex 子项用 `flex:1` 从没有固定高度的父级分配空间，若子项渲染内容量又依赖对自身尺寸的响应式测量，会形成正反馈几何级数增长直到浏览器完全无响应**（踩坑 #70，重大）：连续测得的高度值如果呈稳定倍数关系（如约 4 倍/轮），几乎可确定是"测量值反馈进内容量计算"的反馈环，不是随机抖动或性能问题。驱动测量的 flex 容器必须有不依赖内容、不参与 flex-grow 分配的高度来源（显式固定高度，或确保整条父级链路每层都有确定高度）。
- **`content-box`（默认）盒模型下 `height:100%` + 显式 `padding`，`clientHeight` 会等于 `height + 2*padding`，若 JS 计算滚动坐标时误用了不含 padding 的高度语义，会导致固定量级的坐标系偏移**（踩坑 #71）：现象是"选中索引变化了但滚动到的位置总是错开几项"，容易误判为响应式更新没生效——若偏移量恒定不随机变化，优先怀疑盒模型/坐标系不一致而非逻辑分支写错。要么显式 `box-sizing:border-box`，要么用 JS 让 `element.style.height = (外层高度 - 2*padding) + 'px'` 使含 padding 的 `clientHeight` 精确等于外层高度。
- **Ripple 把 `wheel`/`touchstart`/`touchmove`/`mousewheel` 默认注册为 `passive:true`（对齐浏览器/多数框架的滚动性能优化默认值，见 `@tsrx/core` 的 `PASSIVE_EVENTS` 列表），`onWheel={fn}` 里调用 `event.preventDefault()` 会被浏览器静默忽略，不报错也不警告，只是滚轮事件冒泡后页面照常滚动**（踩坑 #72，重大，Cropper 组件排查发现）：任何需要"阻止默认滚动/触摸行为"的交互（滚轮缩放、触摸手势自定义），一律放弃合成事件的 `onWheel`/`onTouchStart` 绑定，改用 `ref` 回调里 `node.addEventListener('wheel', fn, { passive: false })` 挂原生监听器（并在返回的清理函数里 `removeEventListener`，同一 `ref` 内如果还有 `ResizeObserver` 等其它资源要一并清理，参照踩坑 #69 的具名清理模式）。现象是"逻辑代码看起来完全正确、`preventDefault` 确实被调用了，但页面还是跟着滚动"——不要在组件自己的算法里继续排查，先用 `page.evaluate(() => window.scrollY)` 前后对比确认是不是页面整体在滚动。跨域图片（`<img>` 未同源、CDN 未配 CORS 头）在这类需要 `getImageData`/`toDataURL` 的组件里会直接抛 `SecurityError: canvas tainted`，playground 演示和 e2e 测试素材一律用同源 `data:` URI，不要图省事引用外部图床。
- **受控组件的 Foundation `state` 只在挂载时读一次外部 prop 初值，之后若没有专门的 `effect` 同步，`state` 会永远停在初始快照——`foundation.xxx()` 方法即使受控模式下不写回 `state`，方法内部的计算逻辑仍然读的是这个陈旧 `state`，导致连续多次操作时，第 2 次及以后的调用结果全部错误**（踩坑 #73，重大，UserGuide 组件排查发现，与踩坑 #36 同族但触发条件更隐蔽）：`UserGuideFoundation.next(stepCount, isControlled)` 内部用 `this.getState().current` 计算下一步索引，受控模式下 `setState` 被跳过是对的（避免和外部 prop 打架），但 `state.current` 本身必须靠一个独立 `effect`（`if (!isControlled) return; ...同步 currentProp 到 state`）持续跟随外部 prop，否则第一次调用碰巧因为"陈旧 state 的初值 = 外部 prop 的当前值"而结果正确（掩盖问题），第二次调用时陈旧 state 已经跟外部 prop 分叉，算出的新值是错的——现象是"点第一次下一步正常翻页，点第二次卡住不动，日志里回调参数还是上一次的值"。排查时先怀疑"受控 state 是否有同步 effect"，而不是深挖按钮点击事件本身是否送达（可以用 `MutationObserver` 监听目标节点没有被卸载重建、原生 `addEventListener('click', ...)` 确认事件确实 fired 来排除事件层问题，逼近到状态计算这一层）。任何 Foundation 里既有"受控/非受控双模式"又有"基于当前 state 值做增量计算（如 +1/-1）"的方法，必须在设计阶段就检查受控分支下 state 的同步链路是否闭合，不能只测"单次外部改值→视觉更新对不对"，要测"连续两次内部方法调用，第二次是否读到最新值"。
- **`track(() => ...)` 派生值的计算函数内部如果通过 `foundation.someMethod()` 间接读 state（而不是直接读响应式 `state.xxx`），且该方法内部用 `adapter.getState()`（实现是 `() => untrack(() => state)`）取值，会导致这个 `track()` 派生值永远不会因为 `state` 变化而重新求值——`untrack()` 阻断的是"依赖建立"而不只是"避免死循环"，Foundation 方法专为 effect/事件回调内的"读一次当前值、不订阅后续变化"场景设计的 `untrack` 包裹，一旦被用在 `track()` 计算函数内部读取路径上，等于把整个派生值也变成了"只算一次的静态快照"**（踩坑 #74，重大，Cascader 组件排查发现）：现象是"点击操作后 state 里的字段（如 `activeKeys`）确实更新了（用 `MutationObserver`/直接读 DOM class 能验证），但依赖它的多列面板/搜索结果视觉完全不重新渲染，像是整个响应式链路失效"。修复方式：`track()` 计算函数里凡是要依赖某个 `state` 字段的，必须直接写 `state.xxx`（触发响应式读取），再把这个值传给纯函数（如 `computeColumns(treeData, state.activeKeys, entities)`），不能包一层 `foundation.computeColumns(...)`（哪怕这个方法内部最终也是调用同一个纯函数）——对齐 Tree 组件既有的 `flatNodes = track(() => flattenTreeData(treeData, state.expandedKeys, ...))` 写法，直接读 `state.expandedKeys` 而不是 `foundation.getExpanded()`。这类 bug 用 `console.log` 断点很难发现（因为 state 本身没错、纯函数本身没错，只有"重新求值的触发时机"错了），最快的定位路径是搜索所有 `track(() =>` 的计算体内有没有调用 Foundation 类方法，凡是有的都要重新审视其内部是否经过了 `getState()`/`untrack()`。
- **多选场景下"点击行本身"和"点击行内 checkbox"必须是两个独立的语义（前者展开路径查看子级，后者才是勾选），checkbox 的点击事件若不 `stopPropagation()` 会冒泡到外层容器的 `onClick`，导致两个操作被误合并成一个**（踩坑 #75，Cascader 组件排查发现，对齐 Semi `onItemCheckboxClick` 内的 `e.stopPropagation()`）：現象是多选模式下点击非叶子节点的文字会直接勾选而不是展开子级，用户无法在不勾选的前提下查看下一级有哪些选项——这类"点击语义被合并"的 bug 在真机截图里完全看不出来（DOM 结构、样式都正常），必须真的执行两种点击并分别断言其副作用范围（"点文字只展开、checkbox 状态不变"vs"点 checkbox 只勾选、列数不变"）才能发现。凡是"父容器可点击 + 内部又嵌了另一个可独立点击的交互元素"的组件（checkbox/按钮/链接嵌在可点击行内），都要显式检查内部元素的点击是否需要阻止冒泡，不能假设"反正外层点击也做类似的事所以无所谓"。
- **触发器包裹层若整个套住一个可编辑文本框（而不是 Cascader/TreeSelect 那种不可编辑的纯展示触发器），点击语义不能直接照搬"无条件 toggle"——用户点击输入框内部很可能是为了聚焦打字或移动光标，不是想关闭已经打开的建议面板，无条件 `toggle()` 会把正在使用的面板意外关闭**（踩坑 #76，AutoComplete 组件排查发现）：修复方式是把点击处理拆成"只在关闭态才打开，已打开时点击输入框内部不做任何事"（`if (!visible) open(...)`，不再无条件 `toggle()`），真正的关闭交给点击外部/Esc/选中候选项这几条既有路径。此外，**Playwright 真实鼠标点击（`locator.click()` 或用户操作）会触发完整的事件冒泡（含 `click` 事件），而 JS 的 `element.focus()` 只触发 `focus`/`focusin`、不会冒泡 `click`**——这导致同一组件在"ego-browser 手动用 `el.focus()`验证"和"Playwright e2e 用 `.click()` 验证"这两种方式下，观察到的初始状态可能不同（一个因为没有冒泡副作用面板保持关闭，另一个因为点击本身已经冒泡触发了外层 `onClick` 导致面板提前打开且高亮了第一项）。排查"e2e 断言的索引/高亮永远比预期多一步"这类稳定偏移的失败时，优先怀疑是不是测试用的 `.click()`/`.fill()` 触发了组件里某个包裹层的 `onClick` 副作用，而不是去查 Foundation 的索引计算逻辑——纯函数本身完全正确，只是多算了一次真实点击带来的额外状态推进。修复该 bug 后要额外补一条"面板已打开时再次点击触发器内部，面板应保持打开"的专项回归测试，因为常规的"点击打开/点击外部关闭"测试组合完全覆盖不到这个交互路径。
- **`ScrollList` 的 `.lotus-scroll-list-body` 没有默认高度（`flex-shrink:0` 但不含 `height`），必须显式传 `bodyHeight` prop，否则 `ScrollItem` 内部 `ResizeObserver` 测得 `containerHeight=0`，整个滚动列表塌陷成几乎零高度，DOM 结构和 class 都正常、真机截图也可能因为 Popover 定位在页面下方不易察觉，但列表项的 `getBoundingClientRect()` 会落在视觉上完全不合理的位置**（踩坑 #77，TimePicker 组件排查发现）：现象是 e2e 测试点击列表项时报 `intercepts pointer events`（点击被其它元素拦截），排查时先查目标元素的父级滚动容器有没有显式高度来源，而不是怀疑 z-index/层级遮挡——这类"高度链路断裂"的表现和"z-index 遮挡"表现几乎一样（点击被别的元素截获），但根因和修法完全不同。任何用 `ScrollList` 包 `ScrollItem` 的新组件，接入时必须显式传 `bodyHeight`（像素数或 CSS 长度），不能假设内部会自适应内容撑高。
- **无值/未选中态的默认展示基准如果用 `new Date()`（当前真实时刻），会让"未操作时列表初始滚动到哪一项"随测试运行的实际时间漂移，e2e 断言点击远离基准值的项（如 09 点）在多数时刻会因为该项被自动滚出可视区域之外而点不到**（踩坑 #78，同一次排查发现）：修复方式是仿照 Semi 的 `createDateDefault`——未选中时用"今天 00:00:00"这种固定基准，不用 `new Date()` 的完整当前时刻。更通用的教训：任何"面板默认展示值"的设计，凡是会影响初始滚动/高亮位置的，都要用确定性基准（如当天零点、列表第一项），不能用"当前时刻"这种每次运行都不同的值，否则相关 e2e 测试会变成对运行时刻敏感的隐性 flaky 测试——表现为"平时能过，某些时间段必挂"，比常规的时序 flaky 更难复现和定位。
- **Playwright e2e 断言如果直接比对 `Date.prototype.toLocaleTimeString()` 之类依赖浏览器/系统 locale 的格式化输出（如断言包含 `'09:'`），在配置了非默认 locale 或不同小时制的 CI/本机环境下会得到完全不同的字符串（如 `'9:00:00 AM'` 而非 `'09:00:00'`），导致断言失败但组件本身完全正确**（踩坑 #79）：e2e 里凡是要校验时间/日期数值，优先读组件自身用固定 token 格式化后的展示值（如输入框 `value`，用 `formatTime`/`localeFormat` 等确定性格式化函数产出），不要依赖 demo 演示代码里为了人类可读性用的 `toLocaleTimeString()`/`toLocaleDateString()` 这类 locale 敏感 API 拼出的日志文本作为断言源。
- **`@for` 循环体内某个元素的 `onMouseEnter`/`onMouseMove` 若无条件写入"祖先组件共享 state"（而不是元素自身/最近父组件的局部 state），会让鼠标悬停这个高频、无感知的动作持续触发祖先组件整体重渲染；祖先重渲染又会给所有子组件传入全新的内联箭头函数 prop，如果子组件把 prop 引用变化当成"需要整体换新实例"处理，会导致鼠标经过的目标元素在 Playwright 的 mousedown 与 mouseup 之间被替换/摘除，`click` 事件因目标身份不连续而丢失或落空——现象是 `locator.click()` 报 "element was detached from the DOM, retrying" 且长时间不收敛，或者更隐蔽地直接判定"面板已可见、目标已解析"但点击后值毫无变化（无重试提示，看起来像是没点中却连坐标/命中元素都验证正确），必须用真实 CDP mousedown+mouseup（而非 JS `.click()`）复现，因为纯 JS `.click()` 会绕开这条真实事件路径，直接掩盖问题**（踩坑 #80，重大，DatePicker 组件排查发现，日历网格 range 选择 hover 预览态触发）：日历网格 hover 预览态原先设计成"子组件回调到顶层 DatePicker 共享 state（hoverDay 字段），驱动两侧面板的 `isInRange`/`isHover` 等一大片日期格 class 同时变化"，这个设计本身语义没错（hover 预览确实要影响一整片格子），但把这份状态放在了错误的层级——写在"日历网格自身的局部 state"里同样能满足语义（因为渲染逻辑只需要"当前鼠标在哪一侧面板悬停到了哪一天"这个信息，不需要跨面板共享），却能把重渲染范围收窄到"当前被悬停的那一个 MonthGrid 面板"，不再牵动兄弟面板和顶层组件。修复后点击稳定性问题消失，且无需任何防抖/延时 hack。通用教训：`@for` 列表项的 hover/focus 类"高频触发、纯展示反馈"的状态，默认应该下沉到触发该反馈的最近组件的局部 state，只有当反馈确实需要跨越组件边界（比如触发器 hover 要驱动完全不同子树的展示）时才提到共享 state；写之前先问"这个状态的影响范围真的需要到共享层吗，还是本地就够"。另外，同一次排查确认了"滚轮选择器（ScrollItem）挂载后要等自身 `ResizeObserver` 首次回调才能测出容器高度、进而把默认选中项滚动到视图内可点击的位置"这段初始化延迟是真实存在的（不是 bug），自动化测试点击速度快于这个结算窗口时会点到尚未滚动到位、视觉上仍处于列表顶端的其它项——这与踩坑 #77 是同一类"滚动容器几何未就绪"问题的另一种触发路径，e2e 对滚轮类选择器要么选取默认已可见/居中的项、要么在面板可见后等待一小段时间（如 300ms）再点击，不要求助于 `force: true`（`force` 只能绕过 Playwright 自身的稳定性检查，绕不开"目标坐标此刻是否是想要的元素"这个几何事实，误用会让测试点中错误的项还误判为通过）。
- **lotus 自定义元素的鼠标按下事件一律用 `onMouseDown`（对应原生 `mousedown`），不是 `onPointerDown`——项目里目前没有任何组件使用过 `onPointerDown`，Ripple 是否把这个属性名正确映射到 `pointerdown` 监听未经验证；新组件如果照搬"现代化"的 Pointer Events 命名直觉去写 `onPointerDown`，会在 ego-browser 用 CDP `Input.dispatchMouseEvent` 手测时"看起来完全正常"（因为浏览器会从真实鼠标事件派生合成 `pointerdown`，只要监听器绑定生效就能收到），但换成 Playwright `page.mouse.click()`/`page.mouse.down()` 这类更贴近真实用户操作的路径时完全没有响应——现象是值恒定不变、没有任何报错或重试提示，排查时容易先怀疑坐标计算错误，实际上是事件名本身没有绑对**（踩坑 #81，Slider 组件排查发现）：新组件要在 DOM 元素上绑鼠标按下监听器时，先 grep 一遍 `packages/ripple/src` 里其它组件（如 `basic/resizable/index.tsrx`）用的是什么事件名，照抄已验证过的写法，不要凭"更现代/更该支持触屏"的直觉自己选一个没人用过的属性名。
- **Playwright 的 `page.mouse.click(x, y)` / `page.mouse.move(x, y)` 系列 API 用的是绝对视口坐标，不会像 `locator.click()` 那样自动把目标元素滚入视图**（踩坑 #81 续，同一次排查发现）：如果测试没有显式调用 `locator.scrollIntoViewIfNeeded()` 就直接读 `boundingBox()` 再传给 `page.mouse.*`，量到的坐标可能对应元素滚动到位前（甚至完全不在可视区域内）的位置，点击/拖拽会落在错误的地方，现象和"事件没绑对"几乎一样（值不变化），容易和踩坑 #81 的真正病因混淆——两者都要排查一遍：先确认事件名对不对，再确认坐标测量前有没有先滚动到位。凡是测试代码里用到 `page.mouse.*`（而不是 `locator.click()`/`locator.hover()` 这类会自动处理滚动的高层 API）时，必须在 `boundingBox()` 前加一次 `scrollIntoViewIfNeeded()`。
- **`track()` 派生值经 `foundation.method()` 间接读 state 导致响应式依赖阻断这个踩坑（#74）在 Rating 组件里再次踩中，同一个坑第二次出现**：`track(() => foundation.getStarFillState(index))`/`track(() => foundation.displayValue())` 这类写法，内部方法最终都经 `this.getState()`（`Adapter.getState` 实现是 `() => untrack(() => state)`）取值，`track()` 派生值因此永远不会因 `state.value`/`hoverValue` 变化重新求值——现象是**点击/hover/键盘操作触发的 `onChange`/`onHoverChange` 回调值完全正确**（因为事件处理函数里直接调用 Foundation 方法、Foundation 内部 `setState` 也确实生效了），**但屏幕上的视觉（星星填充 class）纹丝不动**，容易误判为"回调触发了但没传对值"这类完全不同方向的问题，实际上数据链路从头到尾都是对的，只有渲染这一层被冻结。修复方式与踩坑 #74 一致：把需要响应式的字段（如 `state.value`、`state.hoverValue`）直接在 `track()` 计算函数体内读出，再传给一个不经过 `this.getState()` 包裹的纯函数（本例是新增的模块级导出函数 `starFillState(display, index, allowHalf)`，不是 Foundation 类方法）。**教训升级**：Foundation 类里任何"读取当前 state 计算派生值"的方法（哪怕只是像 `displayValue()`/`getStarFillState()` 这样看起来无副作用的只读 getter），只要标注了要给 `.tsrx` 组件在 `track()` 里直接调用，就必须在写的当下问一句"这个方法内部最终走的是 `getState()` 吗"——凡是走的，要么改造成接受"数据"而非"自己去 state 里取数据"的纯函数签名，要么禁止在 `track()` 里调用它、只能在事件回调里用。新组件落地前，建议对着 Foundation 类的每个 public 方法过一遍："这个方法会被 `.tsrx` 的 `track()` 计算函数直接调用吗？如果会，它内部有没有 `this.getState()`？"，而不是等真机验证或 e2e 测出"看起来没反应"才回头查。
- **本地 `npx playwright test` 全绿不代表 CI 上也全绿——CI runner 通常比本机慢，"选完年份滚轮上的项后立即接着点月份滚轮上的项"这类连续、无间隔的编程式快速点击，会在本机侥幸不撞车、却在 CI 上稳定复现失败**（踩坑 #82，DatePicker 的 month/year/monthRange 类型排查发现，真实 CI 失败驱动）：现象是 `getByLabel(...).toHaveValue()` 断言拿到的是"点偏了一位"的值（如期望 3 月实际拿到 1 月，期望某年实际拿到列表最开头的年份），且是稳定复现（不是随机 flaky），排查时先怀疑"点击坐标算错了"，但真正原因是**年月两个滚轮共享同一个 `<ScrollList>` 容器，选中年份后 `yamProps(panelType)` 会在下一次渲染里重新计算出全新的 `years`/`months` 数组和全新的内联箭头函数闭包传给 `<YearMonthWheel>`，这个 props 引用整体换新，足以让内部的月份 `ScrollItem` 重新走一遍"挂载→等 ResizeObserver 首次回调→滚动定位到选中项"的初始化流程**（与踩坑 #77 同源，但触发方式不同——不是组件首次挂载，而是**父级重渲染导致的二次挂载**）；这个初始化窗口比程序化连续点击的间隔更长，真人操作因为存在自然的"看一眼再点下一下"的间隔不会撞上，但脚本紧跟着的第二次点击必然落在旧坐标或尚未定位完成的过渡态上。**验证方法**：先用 `el.click()`（JS 原生方法，不经过坐标）确认底层交互逻辑本身完全正确，排除"点击处理函数写错"的可能性，再用 ego-browser 加真实延迟复现"变快就错、放慢就对"的规律，锁定是几何/时序问题而不是逻辑问题。**修复方式**：不要用固定 `waitForTimeout` 赌一个"够长"的经验值（本次从 300ms 一路加到 CI 环境仍不够，说明这类值本身就不可靠）；改用 `expect(async () => {...}).toPass({ timeout, intervals })` 把"整个选择流程"包起来做兜底重试，且要考虑到 month/year 这类选中即提交并关闭面板的场景——**重试前必须先判断面板/目标视图是否还在，不在就要从最外层触发器重新打开**，不能只重试点击本身（面板已经关掉的情况下继续点击一个不存在的元素只会一直超时，绝不会收敛）；此外测试里"点固定字面量值（如硬编码某个具体年份/月份）"要改成"动态算出离默认展示位置很近的值（当前年/月 +1 之类）"，从源头减少初始滚动窗口内被误点的概率，两种手段搭配使用比单独用其中一种更稳。
- **把子组件需要的一整组 props 打包成一个普通 `const xxx = {...}` 对象字面量再 `<Child {...xxx} />` 展开传入时，这个对象只在组件函数首次执行时计算一次，不会随内部引用的响应式变量变化而重新求值——子组件因此永远只收到挂载时的初始快照，后续所有更新都传不进去**（踩坑 #83，重大，ColorPicker 组件排查发现）：现象是**Foundation 层计算完全正确**（用 `window.__debug` 探针在事件处理函数内验证过，state 确实更新、`foundation.xxx()` 返回的新值完全符合预期），**但拖拽/点击后 DOM 上任何东西都不会变**——手柄位置、色块颜色、输入框回显全部纹丝不动，且没有任何报错、没有任何控制台警告，是最容易被误判为"事件没绑对"（踩坑 #81 那一类）或"响应式依赖阻断"（踩坑 #74 那一类）的一种全新病因，三者外部症状高度相似（都是"逻辑对、画面不对"），排查时必须先用 `window.__debug` 探针确认 Foundation 计算结果本身正确（排除 #74/#81），再检查"传给子组件的 props 是不是包在响应式声明里"。**根因**：`const panelProps = { state, width, onSvDown: handleSvDown, ... }` 这种写法里，`const` 意味着这段对象构造代码只在组件函数体本次求值时跑一次，Ripple 编译器不会像处理 `let &[x] = track(() => ...)` 那样识别出这个对象内部引用了响应式变量、进而在依赖变化时重新执行这段构造代码——即便子组件自己是用 `&{...}` 懒解构接收这些 props（这是踩坑 #30 强调的必要条件，但只是必要不充分），父组件传下去的**引用本身**如果压根没有更新，子组件的懒解构也无从谈起"重新读到新值"。**规避方式**：任何"打包多个响应式来源到一个对象、再整体传给子组件"的写法，必须把对象构造包进 `let &[panelProps] = track<T>(() => ({...}))`，让这个对象本身成为一个会随内部读取的响应式变量变化而重新求值的派生值，而不是普通 `const`。**排查方法论**：新组件只要出现"逻辑验证完全正确（有 debug 探针为证）、但视觉纹丝不动"这个组合症状，需要按顺序排除三种可能——① `track()` 派生值的计算函数体是否经 `foundation.method()`/`this.getState()` 间接取值（踩坑 #74/#78）；② DOM 事件名是否绑对、绑定的元素坐标测量前是否已滚动到位（踩坑 #81）；③ 传给子组件的 props 是不是用了非响应式的 `const` 对象包装（本踩坑）——三者互相独立，不能只查一种就下结论。
- **`@if (expr) {...} @else {...}` 写在"自定义组件的 children slot 内部、且 `expr` 就是这个组件自身接收到的 `children` prop"这个组合下，两个分支会同时判定为 false、渲染出两个占位注释节点，即便用 debug 探针确认 `expr` 求值结果确实是 truthy 也无法让 `@if` 分支生效——这是 tsrx 编译器在这一特定嵌套场景下的边界情况坑，未继续深挖编译器内部实现原因，只确认了复现条件与规避写法**（踩坑 #84，ColorPicker 组件排查发现，`usePopover` 模式下 `children` 缺省时应回退渲染默认色块触发器）：现象是 `<Trigger>` 组件内部写 `@if (triggerChildren) { {triggerChildren} } @else { <DefaultSwatch/> }`，即便把这段逻辑单独抽成一个顶层组件（避免"深层嵌套在别的组件 JSX 里"这个变量）、且用 `window.__debug` 探针确认组件函数体内 `!!triggerChildren === true`，渲染出的 DOM 仍然是两个 `<!---->` 占位注释，`triggerChildren` 分支和它的取反分支都没有渲染任何内容；拆成两个独立的 `@if (expr) {...}` / `@if (!expr) {...}`（而不是一个 `@if/@else`）现象不变，说明不是 `@else` 分支合并逻辑的问题。**规避方式**：把这个位置的条件渲染改写成 JS 表达式层面的 `{triggerChildren ?? <DefaultSwatch/>}`（用 `??`/三元表达式代替 `@if/@else`），同样的求值结果和同样的组件嵌套层级下，三元写法可以正常渲染，`@if/@else` 不行——两者理论上应该编译到等价的渲染逻辑，但实测行为不同。**教训**：`@if/@else` 判断"组件自身接收到的 children prop 本身"这种写法要提高警惕，优先尝试用 `{expr ?? fallback}`/`{expr ? a : b}` 这类内联 JS 表达式实现同样的条件渲染，尤其是当 `@if/@else` 出现"值探针确认条件为真、但两个分支看起来都没生效"这种反直觉现象时，不要在 `@if/@else` 语法本身上纠缠太久，先换成表达式写法验证是否绕过问题，能绕过就直接采用，不必等框架层面修复。
- **`track()` 派生值经 `foundation.method()` 间接读 state 导致响应式依赖阻断这个踩坑（#74，Rating 组件二次复现记录于 #74 续）在 Transfer 组件里第三次踩中，且触发路径与前两次都不同**（踩坑 #85，Transfer 组件排查发现，搜索框输入完全无响应）：写法是 `let &[visibleData] = track(() => foundation.getVisibleData())` 和 `let &[selectAllStatus] = track(() => foundation.getSelectAllStatus())`——这两个 Foundation 方法本身设计成"只读派生值 getter"（`getVisibleData()` 内部读 `this.getState()` 拿 `data`/`inputValue`/`searchResult` 算出可见集合），语义上完全合理，Foundation 单测里也直接调用它们验证过逻辑正确；但一旦被 `.tsrx` 层的 `track()` 直接调用，同样因为 `this.getState()` 最终经 `untrack()` 取值而阻断响应式依赖收集。现象与前两次几乎一致：**在搜索框里打字，原生 `<input>` 的 DOM value 确实实时更新（能在 `input.value` 读到最新输入），Foundation 层的 `state.inputValue`/`searchResult` 也确实被正确 setState 过（用 `window.__debug` 探针在 Foundation 方法内部验证过求值结果完全正确）**，但左侧列表显示的可见项列表纹丝不动，一个都没被过滤掉——这次的排查线索比前两次更隐蔽，因为"input 的 DOM value 在变"这个事实很容易误导排查方向去怀疑"事件绑定没生效"（类似踩坑 #81 的方向），实际上事件、状态更新全部正确，唯独派生视图没有重新渲染。全选按钮的 `allChecked`/`showButton` 判定同理受阻断，导致点击全选后按钮文案卡住不切换到"清空所选"（尽管选中集合本身确实已经变化）。**修复方式**：不在 `track()` 里调用任何返回值依赖 `this.getState()` 的 Foundation 方法，改成在 `track()` 计算函数体内直接读 `state.xxx` 字段，再传给一个不经过 Foundation 实例、不调用 `getState()` 的**模块级导出纯函数**（本例是把 `foundation.getVisibleData()` 换成直接读 `state.inputValue ? state.data.filter(...) : state.data`，把 `foundation.getSelectAllStatus()` 换成直接调用已经导出的纯函数 `calcSelectAllStatus(visibleData, state.selectedItems)`——这个纯函数本来就存在于 Foundation 同名模块里，只是不能经 `foundation.` 实例方法转发调用，要绕开实例、直接 import 纯函数本体）。**教训累积（第三次同类踩坑后的操作纪律）**：这类 bug 已经连续三个组件（DatePicker `#74` → Rating `#74`续 → Transfer 本次）复现，说明"Foundation 提供一个方便的只读 getter 方法、`.tsrx` 层图省事直接在 `track()` 里调用它"是一种自然但危险的编码直觉，必须养成检查清单：**新组件写完任意一处 `track(() => foundation.xxxMethod())` 时，立刻追问该 `xxxMethod` 内部有没有调用 `this.getState()`**（哪怕只是间接调用另一个也调用了 `getState()` 的私有方法）——有就必须拆成"纯函数 + track 里直接读 state 传参"两段式，不能等真机验证/e2e 测出"看起来毫无反应"才回头排查；同时这次的排查经验补充一条新识别信号：**"DOM 层某个底层原生元素的 value 确实在变，但依赖它的更高层派生视图纹丝不动"，和"回调触发了、Foundation state 也确实更新了，但视觉完全冻结"是同一类阻断信号的两种不同外在表现，遇到任何一种都应该优先怀疑这类响应式阻断，而不是先怀疑事件绑定或数据流本身出错**。
- **`display:flex; flex-direction:column` 容器的直接子项，即使显式设置了内联 `style="height: 2400px"` 这类具体像素值，也会被 flexbox 默认的 `min-height:auto` 隐式压缩到不超过父容器可用空间——`getAttribute('style')` 能读到设置的值，但 `getComputedStyle().height` 和真实占用空间会是被压缩后的更小值，父级 `scrollHeight` 因此远小于预期，导致依赖这个高度撑开滚动区域的场景（虚拟滚动的 spacer 元素）完全失效**（踩坑 #86，Transfer 组件 virtualize 虚拟化功能排查发现）：现象是虚拟滚动的可见区间计算（`calcVirtualRange`）本身完全正确（用 `window.__debug` 探针验证过 `totalHeight` 算出的是期望的 2400px），已选列表全选后 header 正确显示"60 项已选"，但滚动容器 `scrollHeight` 却只有几百像素、手动设置 `scrollTop` 会被浏览器 clamp 到远小于期望的值，导致滚动后可见项完全不切换（或切换幅度远小于预期）——容易被误判为"虚拟化计算逻辑本身有 bug"，但用 debug 探针核实计算结果正确后，应该转向检查"计算结果有没有被正确应用到 DOM 布局"这一层。根因：撑开虚拟滚动高度的 spacer 元素（`.lotus-transfer-virtual-spacer`）的父容器（`.lotus-transfer-list-virtual`）同时套用了另一个基础 class（`.lotus-transfer-list`）的 `display:flex; flex-direction:column` 样式（这个基础 class 是给非虚拟化的普通列表用的纵向排列），spacer 作为这个 flex 容器唯一的子项，触发了 flexbox 规范里"flex item 的 `min-height` 默认是 `auto`（等价于其内容的最小高度），当没有更高优先级的收缩豁免时会被压缩到父容器允许的范围内"这条隐式规则，即使 spacer 自身 `height` 内联样式写了具体像素值也不例外。**修复方式**：给 `.lotus-transfer-virtual-spacer` 补一条 `flex-shrink: 0`，显式关闭 flex 收缩，撑开高度立即生效。**通用教训**：任何"用一个内层元素的固定/计算高度撑开外层滚动容器"的实现模式（不限于虚拟滚动，任何依赖"子元素高度决定父元素 scrollHeight"的场景），如果外层容器恰好是（或复用了）一个 `display:flex` 布局的 class，必须显式给撑开高度的那个子元素补 `flex-shrink: 0`，不能假设"我设置了 height 它就一定生效"——flex 容器下高度值被静默压缩，不会有任何报错或告警，只能通过 `getComputedStyle()` 读实际值或对比 `getAttribute('style')` 与 computed 值的差异才能发现，和踩坑 #68（scoped CSS 不同组件作用域不生效）的排查方式一样隐蔽，都要求"设了样式不代表它真的生效"这条排查纪律。
- **`if (cond) { for (const x of arr) singleStatement; }`——在 `if` 代码块内部嵌套一个"不带花括号的 `for...of` 单语句循环体"，会导致 tsrx 编译器（`@tsrx/typescript-plugin`）解析崩溃（`Cannot read properties of undefined (reading 'map')`），且报错行号完全不指向真正出问题的这一行，而是随机漂移到文件里其它毫不相关的位置（本次漂移到了同文件里另一个组件函数的签名行），产生几十条看似无关、互相矛盾的连锁语法错误，是本次会话排查耗时最长的一个坑（从最初报错到定位真实病灶经过了约30轮系统性二分排查）**（踩坑 #87，重大，Upload 组件 `xhrUpload` 函数排查发现，两处写法都是 `if (args.xxx) { for (const key of Object.keys(args.xxx)) 单行语句; }`）：现象是把两个组件（`FileCard`+`Upload`）放在同一个 `.tsrx` 文件里，`typecheck` 报出的错误集中在 `FileCard` 函数签名和 `<style>` 块内的 CSS 多选择器逗号写法附近（如 `error TS1003: Identifier expected` 精确指向函数签名的解构参数列表那一行），但把 `FileCard` 单独抽出来测试却完全通过——反复怀疑并排除了"函数参数过多"、"属性重命名解构 `fileList: fileListProp`"、"CSS 多选择器逗号换行"、"两个连续的 `let &[x] = track()` 声明"、"可选链调用 `onRemove?.(item, list)`"、"模板字符串里的中文冒号"、"不带参数的 `catch {}`"等十余种假设，全部被逐一独立验证排除（每种写法单独抽出都能正常编译）。**真正的排查突破口**：给"整个文件截断到 N 行 + 补两个额外的 `}`"做二分，如果补了额外的 `}` 之后崩溃状态从"crash"变成"能正常报出语法未闭合错误"，说明原文件确实存在真实的未闭合结构，而不是某个孤立语法元素的问题；再对这个"缺失闭合"的范围做精确二分，才最终定位到 `if (args.data) { for (const key of Object.keys(args.data)) formData.append(...); }` 这一具体写法。**规避方式**：`for...of`（以及大概率同类的 `for`/`while`）循环体只要出现在被另一层 `if`/`for` 等控制流包裹的上下文里，一律显式加花括号，不写单行省略花括号的循环体——即便顶层单独一个 `for (const x of arr) stmt;`（不嵌套在别的控制流里）本身是能正常编译的，只有"被外层 `if` 块包裹"这个具体组合才会触发崩溃，但为了不必每次都记住这条边界规则，最稳妥的做法是**全项目的循环体一律不省略花括号**，不给这类崩溃留下任何触发面。**排查方法论沉淀**：tsrx 编译器对语法错误的定位在某些崩溃场景下完全不可信（报错行号可能指向文件中任意位置的、语法完全正确的其它代码），遇到这种"错误信息互相矛盾、跨越多个不相关代码块"的连锁报错时，不要在报错指向的位置死抠，应该转向"整个文件/函数体逐段二分定位真实病灶范围"这一更笨但更可靠的方法，且要优先怀疑"是否存在未闭合的花括号/语句"这类结构性问题，而不是纠结某个具体语法元素本身对不对。
