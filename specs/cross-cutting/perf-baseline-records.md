# 性能基线记录

> 记录规范见 `specs/cross-cutting/perf-baseline.spec.md`。核心指标 INP：< 200ms 合格，200-500ms 需优化，> 500ms 不可接受。

## AiChatDialogue — 2026-08-28 (commit 255f2ac)

环境：MacBook Pro (arm64, macOS 26.5.1) / Playwright bundled Chromium 1.62.1 / production build（`vite build` + `vite preview`，非 dev server）

数据规模：单条 assistant 消息，模拟真实 SSE 场景下每 50ms 到达一个 `response.output_text.delta` 块（对齐 OpenAI Response API 的典型 token 到达速率），归约器为 `streamingResponseToMessage`——每次调用都是纯函数全量重算（`state.outputs` 重建为新 Map，`content`/`output_text` 用 `Array.from()`/`join()` 重新生成新数组和新字符串，不做增量 diff），组件层 `@for (state.chats; key message.id)` + `DialogueBox` 内 `track<AiContentItem[]>(() => normalizeAiContent(message.content))` 把整条消息内容作为一个 track 单元，因此每次追加理论上都会触发该消息对应 `DialogueBox` 内容区域的整体重新计算。

测量方法：每次点击"追加流式增量"（真实走 `streamingResponseToMessage` → `onChatsChange` → `state.chats` 重赋值 → 组件重渲染的完整链路，非 mock），用 `performance.now()` 记录点击到两帧绘制完成（`requestAnimationFrame` ×2，覆盖布局+绘制）的耗时，作为该次交互 INP 的近似值。

| 场景 | 操作 | 耗时 | 判定 |
|---|---|---|---|
| 短回复（连续 40 次追加，累计约 40 个 delta 块） | 单次追加 → 下两帧绘制完成 | 均值 14.7ms，p50 14.9ms，p95 15.7ms，max 16ms | 合格（远低于 200ms 线，方差极小） |
| 长回复（连续 100 次追加，观察随文本变长的退化趋势） | 前 10 次均值 vs 后 10 次均值 | 前 14.71ms → 后 15.38ms，增长比例 1.045× | 合格（几乎无退化，全量重算的开销在千字级文本下可忽略） |

判定结论：**当前实现性能达标，无需优化**。全量重算 content/output_text 的设计（未做增量 diff）在实测的文本量级下代价可忽略不计（<1ms 级别的额外开销），`track()` 把整条消息内容作为一个单元的粒度虽然偏粗（理论上任意字段变化都会触发该条消息内容区域整体重算），但结合 Ripple 细粒度响应式运行时本身的开销极低，加上单条 AI 回复的现实文本量级（通常几百到几千字，远未到需要担心的规模），实测未观测到需要优化的信号。若未来场景扩展到"多条消息同时流式生成"或单条回复长度显著超出当前测试量级（如包含大段代码块的万字长文），应重新走一遍本流程复测，不能依赖本次结论直接外推。

后续优化方向（当前非必需，仅记录以防未来复测超标）：若要收紧 `track()` 粒度，可考虑把 `output_text` 拆成独立的细粒度 track 单元、只让文本节点本身响应式更新，而不是让整个 `contentItems` 数组重新计算；但这属于"预先优化未出现的问题"，本次不实施。

## Select / Cascader / TreeSelect — 2026-08-28 (commit d029983 起，含本次新增 Select filter 功能)

环境：MacBook Pro (arm64, macOS 26.5.1) / Playwright bundled Chromium 1.62.1 / production build（`vite build` + `vite preview`，非 dev server）

数据规模：1 万节点，均开启 `virtualize={{ height: 240, itemSize: 32 }}`（`base/virtual-list.ts` 固定行高虚拟滚动，三者复用同一份纯算法实现）。Select 为扁平 1 万条 `optionList`；Cascader/TreeSelect 为"1 个根/父节点 + 1 万个扁平子节点"结构（虚拟滚动只发生在单列/单层，多级级联的深层嵌套不影响本次测量的虚拟化路径，故不额外构造多层结构）。三者均同时开启 `filter`/`filterTreeNode` 搜索能力（Select 的 `filter` 为本次新增，Cascader/TreeSelect 原有）。

测量方法：`performance.now()` 记录「面板打开」（点击 trigger 到两帧绘制完成）与「搜索输入」（搜索框派发 `input` 事件到两帧绘制完成）两个场景，`requestAnimationFrame` ×2 覆盖布局+绘制，各场景重复测量 4~6 次。搜索关键词均设计为只命中 1 条结果（如 `选项 9999`/`city-9999`/`node-9999`），确保搜索场景同时覆盖"虚拟滚动区间基于过滤后的新数据重新计算"这条路径。

| 组件 | 操作 | 耗时 | 判定 |
|---|---|---|---|
| Select | 面板打开 | 均值 11.4ms，max 12.1ms | 合格 |
| Select | 搜索输入响应 | 均值 13.4ms，max 14.6ms | 合格 |
| Cascader | 面板打开 | 均值 11.8ms，max 14.8ms | 合格 |
| Cascader | 搜索输入响应 | 均值 16.4ms，max 17.7ms | 合格 |
| TreeSelect | 面板打开 | 均值 12.8ms，max 13.8ms | 合格 |
| TreeSelect | 搜索输入响应 | 均值 12.8ms，max 18.3ms | 合格 |

判定结论：**三者均达标，远低于 200ms 合格线，无需优化**。三者共用同一份 `virtual-list.ts` 固定行高虚拟滚动算法，1 万节点规模下面板打开与搜索过滤后的虚拟滚动区间重算均在毫秒级完成，符合"虚拟化 + O(1) key 映射"的既有优化手段清单预期。此前 Phase 4 spec 长期缺失这三个组件的正式基线记录（仅有 AiChatDialogue 一条），本次一并补齐，Phase 4 第 27 行验收项自此满足。
