---
title: AiChatDialogue AI 对话
category: 展示类
---

AI 对话消息流展示（不含输入框——lotus 把输入框拆成独立的 `AiChatInput` 组件，两者配对但互相独立，本组件只负责渲染 `chats`）。核心能力是流式内容渲染：`streamingResponseToMessage`/`streamingChatCompletionToMessage` 归约器按 `sequence_number` 顺序处理增量块（含无序缓冲与容错），供外部 SSE 事件处理器直接调用累积成完整消息。

## 代码演示

### 如何引入

```tsrx
import { AiChatDialogue } from '@lotus/ripple';
```

### 基本用法

`chats` 传入即受控，每条消息的 `content` 可以是纯文本或结构化的 `AiContentItem[]`（`reasoning`/`tool_call`/`output_text` 等块）。

```tsrx demo
../../src/demos/show/ai-chat-dialogue/basic.tsrx
```

### 流式响应

用 `streamingResponseToMessage(chunks, state)` 归约器处理 SSE 增量块，返回 `{ message, nextState }`，`nextState` 传入下一次调用形成累积链。

```tsrx demo
../../src/demos/show/ai-chat-dialogue/streaming.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| align | 消息对齐方式 | `'leftRight' \| 'leftAlign'` | `'leftRight'` |
| chats | 消息数组，传入即受控 | `AiChatMessage[]` | 无 |
| disabledFileItemClick | 是否禁用文件项点击 | boolean | `false` |
| getAiChatDialogueApi | 获取命令式 API（`selectAll`/`deselectAll`/`scrollToBottom`/`scrollToTop`） | `(api: AiChatDialogueApi) => void` | 无 |
| hints | 空状态下展示的提示语列表 | `string[]` | 无 |
| messageEditRender | 自定义消息编辑态渲染 | `(message) => any` | 无 |
| mode | 消息展示模式 | `'bubble' \| 'noBubble' \| 'userBubble'` | `'bubble'` |
| onAnnotationClick | 点击引用标注的回调 | `(item) => void` | 无 |
| onChatsChange | 消息数组变化时的回调（选中态、编辑态等内部交互驱动） | `(chats) => void` | 无 |
| onFileClick | 点击文件项的回调 | `(item) => void` | 无 |
| onHintClick | 点击提示语的回调 | `(hint) => void` | 无 |
| onImageClick | 点击图片项的回调 | `(item) => void` | 无 |
| onMessageBadFeedback | 点踩回调 | `(message) => void` | 无 |
| onMessageCopy | 复制消息回调 | `(message) => void` | 无 |
| onMessageDelete | 删除消息回调 | `(message) => void` | 无 |
| onMessageEdit | 编辑消息回调 | `(message, content) => void` | 无 |
| onMessageGoodFeedback | 点赞回调 | `(message) => void` | 无 |
| onMessageReset | 重新生成回调 | `(message) => void` | 无 |
| onReferenceClick | 点击引用条回调 | `(message) => void` | 无 |
| onSelect | 选中状态变化回调（`selecting` 模式下） | `(selectedIds) => void` | 无 |
| renderHintBox | 自定义提示语渲染 | `(args) => any` | 无 |
| roleConfig | 角色展示配置（头像/名称） | `DialogueRoleConfig` | 无 |
| selecting | 是否处于多选模式 | boolean | 无 |
| showReference | 是否展示引用条 | boolean | `false` |
| showReset | 是否展示重新生成按钮 | boolean | `true` |

`AiChatMessage` 关键字段：`{ id, role, content?: string | AiContentItem[], status?, like?, dislike?, editing? }`。

## Accessibility

流式内容更新时的屏幕阅读器体验是本组件的重点无障碍设计：全程 `aria-live="polite"` 会导致每次 token 追加都触发播报（等同逐字打断朗读，不可用）。已按行业最佳实践（生成期间抑制播报、完成后播报一次完整结果）实现——`isAnyMessageStreaming(chats)` 纯函数驱动消息列表的 `aria-live` 在存在 `in_progress` 消息时降级为 `'off'`，全部消息完成后恢复 `'polite'`，已通过 Foundation 单测 + e2e 回归 + 真机验证三阶段状态转换。

## 设计变量

- `--lotus-color-bg-0` / `-bg-1`
- `--lotus-color-text-0` / `-text-1` / `-text-2`
- `--lotus-color-primary`
- `--lotus-color-ai-general`（AI 消息标识渐变色）
- `--lotus-border-radius-medium`
