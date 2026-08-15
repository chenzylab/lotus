# Semi Design 设计博客要点摘录

> 来源：https://semi.design/blogs/zh-CN/article/{AI,i18n,Performance,PerfBaseline,FA,UITest,Theme,Accessibility}
> 抓取日期：2026-08-12。仅摘录对 lotus 有实操参考价值的部分，完整原文请回源查阅。

## AI — AI 体验设计原则

- 交互模型：`用户输入 → 过程处理 → 结果输出 → 循环反馈`。
- 五大设计原则：**意图可表达**（输入阶段）、**可解释性**、**信任校准**、**可控性**（"AI 是协作者，不是决策者"）、**人在环路**（过程/反馈阶段）。
- 组件划分四阶段：路径引导（Wayfinder：新手引导/建议/提示模板）→ 内容输入 → 过程感知与控制（展示 AI 思考过程 + 暂停/修改/引导）→ 结果呈现与控制（复制/重新生成/调整语气）→ 循环反馈（点赞/点踩/纠错/收藏）。
- 视觉上用紫蓝渐变色系标识 AI 能力边界。
- **对 lotus 的启示**：Phase 中的 `Other/AI` 分类组件（AiChatDialogue, AiChatInput, AiComponent 等）应保留"过程可中断、结果可复核"的交互位，Token 层需要预留 AI 专属渐变色变量（对应 `--lotus-color-ai-*`）。

## i18n — 国际化设计规范

- 六大影响因素：文化差异、语言特性、市场环境、用户习惯、政策法规、技术环境。
- 文案长度：默认用省略号截断；允许高度扩展的场景走折行；导航/数字类内容建议全量展示不截断。
- RTL：核心内容锚点从左上移到右上；日期/标签等专有名词顺序需调整；方向性图标需要镜像。
- 视觉禁忌：动物象征（猫头鹰/猪/狗在特定文化含义不同）、人物多样性表现需谨慎。
- **对 lotus 的启示**：`@lotus/locale` 需要预置中/英/日/韩/阿拉伯语文案 token；Foundation 层不应假设文案定长；RTL 作为一等公民在 Token 层通过逻辑属性（`margin-inline-start` 而非 `margin-left`）实现，而不是事后加补丁。

## Performance — 性能优化实践

- **CSS 动画优先于 JS 动画**：复杂场景下 CSS 动画 60fps vs JS 动画 4-9fps。lotus 组件动画默认用 CSS transition/animation，仅在必须精确控制时序时才用 JS。
- 大数据组件优化模式：
  - 减少无意义计算/判断（如 Cascader 移除多余 isEmpty 判断）
  - key 生成从 O(n) 降到 O(1)
  - 树形结构拍平 + 虚拟化 + HashMap 映射（Tree：1.1万节点渲染耗时降 96%）
  - 延迟计算到交互时刻，而非渲染时立即计算（Typography 省略逻辑）
- 内存泄漏防护：基于发布订阅 + WeakRef 的事件委托，组件卸载自动清理监听器。
- **对 lotus 的启示**：Ripple 本身是 fine-grained reactivity（非 VDOM diff），部分 React 特有的性能问题（key 重算、无谓 re-render）天然规避，但虚拟化/拍平数据结构的思路仍适用于 Tree/Table/Select/Cascader 等组件的 Foundation 层设计。

## PerfBaseline — 性能基线方法论

- 核心指标：**INP (Interaction to Next Paint)**。< 200ms 优秀，200-500ms 需改进，> 500ms 差。
- 大数据交互类组件（Select/Tree/TreeSelect/Cascader）以 200ms 为合格线。
- 基线需要标注：测试环境（设备/浏览器/生产模式）、数据规模、具体操作耗时。
- **对 lotus 的启示**：`specs/cross-cutting/perf-baseline.spec.md` 照此方法论建立 lotus 自己的基线表（不能照抄 Semi 的具体数值，因为运行时不同），每个大数据组件在 Phase SPEC 验收标准中引用该基线。

## FA — Foundation/Adapter 分层架构

- 核心问题：交互逻辑与技术框架无关，如何避免多框架重复实现。
- **Foundation 层**（框架无关）：业务逻辑、状态计算、条件判断，不碰 DOM。
- **Adapter 层**（框架相关）：DOM 操作、事件绑定、状态管理，用具体框架 API。
- 实现方式：Foundation 类定义 `init()`/`handleChange()` 等方法；Adapter 通过 getter 提供 `getState()`/`updateActiveKey()` 等接口供 Foundation 调用（依赖倒置：Foundation 不 import Adapter，Adapter 把自己的能力注入给 Foundation）。
- 权衡：前期抽象设计成本高、代码量略增，换来移植成本大幅降低、逻辑与视图分离。
- **对 lotus 的启示**：这正是 `packages/foundation` + `packages/ripple` 分包的依据。Adapter（Ripple 组件）持有 Foundation 实例，通过一个 `Adapter` 接口对象把 `track()` 状态的 getter/setter 注入 Foundation；Foundation 只依赖这个接口，不 import `ripple`。

## UITest — 测试策略

- 三层测试：单元测试（Jest+Enzyme+JSDOM+Sinon）、E2E（Cypress，补足 JSDOM 没有布局导致 `getBoundingClientRect` 返回 0 的短板）、视觉回归（Chromatic，对比 story 快照）。
- 覆盖率通过合并多工具报告统计：语句 86.5%、分支 74.9%、函数 84%、行 86.7%，目标线覆盖率 90%。
- CI：Github Action 并行跑各类测试 → 上传 coverage artifacts → istanbul-combine 合并 → Codecov 展示 + PR 评论。
- **对 lotus 的启示**：lotus 用 Vitest 替代 Jest+Enzyme（跑 Foundation 纯逻辑单测），Playwright 替代 Cypress+Chromatic（真实浏览器交互 + 视觉快照两用）。分工原则不变：**能在 Foundation 层单测覆盖的逻辑不要重复写 E2E**，E2E 只覆盖布局计算、弹层定位、真实用户操作路径。详见 `specs/cross-cutting/testing.spec.md`。

## Theme — 主题系统架构

- 色彩算法：HSB 色轮，色相环 24° 一份分 15 份；指定品牌色后计算其与最近锚点色的偏移量 Δ，整体旋转色轮同步调整饱和度/明度，从一个品牌色推导 160 个基础色阶。
- 每色相生成 10 级色阶（0-9），锚点参考经典绘画色轮 6 色，依据 Munsell Peak Chroma Value（不同色相的"最强烈"明度不同：黄需要更高明度，蓝相反）。
- 暗色模式：整体降饱和度、提明度，避免高饱和色在深色背景的视觉疲劳。
- **四层变量架构**：L4 基础色阶（数值）→ L3 全局语义变量（如 `--color-primary`）→ L2 组件级变量 → L1 组件样式消费。下层引用上层，任意层级可覆盖，修改级联传导。
- DSM 工具：指定一个品牌色 → 一键生成 320 色阶（浅+深两套）+ 联动字体/圆角 → SCSS 编辑器精修 44 个组件 → 发布 npm 包。
- **对 lotus 的启示**：`packages/tokens` 采用同样的四层结构（重新推导颜色算法，不复用 Semi 代码，但沿用"品牌色 → 算法生成色阶 → 语义层 → 组件层"的骨架），命名前缀 `--lotus-*`。是否做类似 DSM 的可视化定制工具属于后置的 `@lotus/cli`，第一期只需保证「改一个品牌色变量即可重新生成完整色阶」的 CLI/脚本能力。

## Accessibility — 无障碍规范

- 依据 WCAG 2.0（未来考虑 WCAG 3.0 + APCA 对比度标准）+ ARIA 语义化。
- 对比度：常规文本 ≥ 4.5:1，大文本(≥18px) ≥ 3:1，交互状态（hover/active/focus）与相邻色 ≥ 3:1，描边组件描边与底色 ≥ 3:1。
- 深色模式避免纯黑背景（光晕效应）；不用颜色作为唯一视觉提示（需搭配图标/文本/下划线/纹理）。
- 键盘：Tab/Shift+Tab 切焦点、方向键导航选项、Enter/Space 激活、Esc 关闭弹层；焦点初始位置按操作风险分配（破坏性操作焦点在最安全元素，如"取消"）；焦点消失后需还原到触发前位置。
- 媒体：图片需 `alt`（图标+文字按钮的图标部分可不加，避免重复播报）；音视频需字幕。
- 动画：禁止每秒闪烁超过 3 次（光敏性癫痫风险）。
- 200% 缩放下仍需保持可读与功能完整。
- **对 lotus 的启示**：`.claude/skills/a11y-audit/SKILL.md` 直接把这些标准转成组件自检 checklist；受控弹层类组件（Popover/Modal/Dropdown）必须显式处理 Esc 关闭后的焦点归还，这是 Ripple Adapter 层的强制实现项，不能留给业务方。

---

## customize-theme — 主题定制官方文档要点

> 来源：https://semi.design/zh-CN/advanced/customize-theme

- 三种接入优先级递增的覆盖方式：npm 主题包 < 本地 SCSS 覆盖 < 插件参数动态注入。
- 构建工具集成：Webpack 插件指定 `theme`/`include`/`variables`；支持 `prefixCls` 改类名前缀。Vite 插件类似，额外支持 `cssLayer`（CSS Layer 隔离）和 `omitCss`（配合 Next.js 等限制全局 CSS 导入的场景）。
- 组件级变量覆盖需要显式在 `theme` 配置对象里声明 `name` + `include`。
- **对 lotus 的启示**：`@lotus/tokens` 产出标准 CSS 变量文件 + 一份 Vite 插件（覆盖变量注入 + 可选 `prefixCls`），不做 Webpack 版本（lotus 生态首选 Vite）。`cssLayer` 思路值得直接抄：用 `@layer lotus-tokens, lotus-components, app` 隔离层级，方便消费方覆盖样式优先级可控。
