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

## 对后续组件开发的结论性指导

- 所有涉及状态机的组件，Foundation 层一律继承 `packages/foundation/src/base/adapter.ts` 的 `Foundation<S>` 基类，不要重新发明 Adapter 接口形状。
- Adapter（`.tsrx`）侧的 `track()` + `new XxxFoundation({ getState, setState })` 三行样板代码可以直接复制本文档的范式，只需替换 State 类型和 Foundation 类名。
- 新组件开工前，先过一遍上面「已知踩坑」六条，尤其是 Fragment 包裹（#1）和 `tsrx-tsc`（#5）这两条——分别是最容易在编码阶段和 CI 配置阶段踩、且报错信息不直接指向根因的坑。
- **任何新包只要直接 import `.tsrx` 文件**（无论是组件包还是应用包），typecheck 脚本必须用 `tsrx-tsc` 而非 `tsc`，`package.json` 需要按上面 #5 的写法锁定 `typescript@5.9.3` 别名依赖 + `@tsrx/typescript-plugin` 依赖 + `tsconfig.json` 的 `plugins`/`jsxImportSource` 配置，四者缺一不可。
