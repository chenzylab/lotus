---
name: semi-porting
description: 需要参考本地 ~/i/semi-design 仓库的 API 设计、或搬运可复用资产（图标 SVG、纯算法代码、色彩算法思路）到 lotus 时使用。定义合规检查清单与改写要求，避免残留 Semi 品牌痕迹或引入不兼容代码。
---

# semi-porting

## 何时使用

- 设计某组件 Props API 前，想参考 Semi 对应组件的接口设计
- 需要搬运 SVG 图标资源到 `packages/icons`
- 需要参考 Semi 的纯逻辑代码（无 React 依赖的部分）作为 Foundation 实现的起点

## 仅供参考 vs 可直接搬运，如何判断

**可直接搬运（过改写检查后）**：
- `packages/semi-icons` 的 SVG 源文件（图标是视觉资产，不含框架逻辑，改写成本低）
- `packages/semi-foundation` 下确认不依赖 React 的纯计算逻辑片段（如日期计算、色彩数值换算），前提是先用 `grep -r "react"` 确认该文件无 React import

**仅供参考，禁止直接复制粘贴**：
- 任何 `.tsx`/React 组件实现（`semi-ui` 下的所有内容）——架构模型完全不同（VDOM diff vs Ripple 细粒度响应式），复制会导致以 React 心智模型写 tsrx，产出反模式代码
- Foundation 类中调用 React 特定 API 的部分（`this.getAdapter().getProp()` 等 Semi 自己的 Adapter 接口设计可以参考思路，但接口签名要按 lotus 的 `Adapter<S>` 约定重新设计，不是照抄）

## 搬运前合规检查清单

- [ ] 确认 Semi Design 的开源协议（本仓库 `~/i/semi-design/LICENSE`）允许该用途；lotus 若要长期使用搬运资产，在 lotus 仓库对应位置保留必要的来源/协议声明（不是简单不提，也不是照抄 Semi 的 License 文件头）
- [ ] 搬运的代码/资产中所有 `semi` 字样命名（变量名、类名、CSS 类前缀 `.semi-*`、CSS 变量 `--semi-*`、包名引用）全部替换为 `lotus` 对应命名
- [ ] SVG 图标的 `viewBox`、path 数据可保留（视觉资产本身不含品牌文字），但文件名、导出的组件名、元数据字段需按 `packages/icons` 自己的命名规范重写
- [ ] 搬运的算法代码需要补充或重写单测（不能假设 Semi 原有测试直接适用，尤其如果做了签名调整）
- [ ] 若代码涉及 Semi 的内部工具函数依赖（如 `semi-foundation/utils`），需要连带评估这些依赖是否也要搬运/重写，不要出现"搬了一半，缺依赖跑不起来"的半成品

## 使用姿势建议

优先用 `Read`/`Grep` 直接查看本地 `~/i/semi-design` 源码定位实现（比如 `packages/semi-foundation/<component>/foundation.ts` 看状态机设计、`packages/semi-ui/<component>/index.tsx` 看 Props 接口），理解设计意图后，在 lotus 里用 tsrx/Ripple 的语言习惯重新表达，而不是逐行翻译。API 设计上可以合理偏离 Semi（如 lotus 的 `Adapter` 接口约定与 Semi 的 Foundation 基类设计不同），不需要 1:1 对齐。

**基础交互能力（浮层定位/拖拽/虚拟滚动）不适用本 skill 的"直接搬运"路径**——这类能力遵循 AGENTS.md 的"基础能力自研"条款，即使 Semi 有现成实现也只能作为设计参考，不做代码级搬运，因为 Semi 的这类实现同样绑定 React 心智模型。

## 文档站 demo/md 与组件代码搬运的口径不同：demo 要严格全量对齐，代码只需参考

上面几节讲的是**组件实现**（Foundation/Adapter 代码）的搬运口径——"仅供参考，用 lotus 语言习惯重新表达"。但 `apps/docs` 里的 md 文档和 demo 文件是另一套口径：**必须与 `~/i/semi-design/content/<category>/<component>/index.md` 严格全量对齐**，不是参考，是照着写：

- **`### 小节标题` 逐字对应**：Semi 原文叫"基本用法"就不能写成"基础用法"，叫"Flex 布局"就不能拆成"水平排列方式"；小节数量、顺序也要与原文一致，不要合并、拆分、增删（除非该 demo 依赖的 Semi 组件 lotus 完全没有对应能力，此时才允许调整，且要在正文如实注明差异原因，不能悄悄替换成看起来相似的内容）。
- **demo 内容逐一对应**：每个 demo 展示的 prop 组合、文案（如"col-8"、"次要"、"col-6 pull-18"）尽量照抄 Semi 原文，只替换成 lotus 自己的组件/包名引用（`@douyinfe/semi-ui` → `@lotus/ripple`）和必要的语法转换（`jsx live=true` → `tsrx demo`，React 组件写法 → tsrx 组件写法）。
- **API 参考表格逐字段核对**：属性名、说明文案、类型、默认值都要跟 Semi 表格一一核对，不要遗漏字段，也不要用自己的措辞改写"说明"列（除非该属性在 lotus 里的实际行为确实与 Semi 不同，此时要如实描述 lotus 的真实行为，而不是照抄 Semi 可能已经不适用的描述）。
- **如实标注差异，不要用自己的结构掩盖差异**：如果 lotus 的组件设计天然偏离 Semi（比如 Grid 的 Row 不需要 `type="flex"` 就默认启用 flex），在对应小节正文里用一两句话点明这个差异，但小节标题、demo 覆盖的场景仍要按 Semi 原文保留，不能因为"lotus 没有这个 prop"就整个删掉对应 demo 或改成自造的小节结构。
- **验收方法**：写完后跑 `grep -oE '^### .*' <semi-md>` 和 `grep -oE '^### .*' <lotus-md>` 对比小节标题列表，必须完全一致（除非有上述"完全没有对应能力"的正当理由，且已如实注明）；同时把两份 md 全文并排读一遍，逐段核对 demo 内容和 API 表格，不能只对标题、不核内容。
- **踩过的坑**：Divider 的"基本用法"曾被简化成缺失垂直分割线/虚线组合的两段式极简版，"包含内容"曾被漏掉整节；Space 的"基本用法"曾错写成"基础用法"；Grid 的"Flex 布局"/"Flex 子元素垂直对齐"曾被拆分重命名为"水平排列方式"/"垂直对齐方式"，还擅自新增了 Semi 原文没有的"元素位移"小节。这些偏差都是在没有逐字核对原文的情况下、凭记忆或"合理推断"重写导致的，必须用上面的验收方法逐一查出并改回原文结构。
