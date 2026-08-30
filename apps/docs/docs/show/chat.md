---
title: Chat 聊天（基础版）
category: 展示类
---

聊天消息列表 + 输入框的基础壳层。本阶段只做消息渲染与发送，不包含 AI 过程感知/流式响应 UI（这部分由 `AiChatDialogue` 组件承担）。

## 代码演示

### 如何引入

```tsrx
import { Chat } from '@lotus/ripple';
```

### 基本用法

`chats` 传入即为受控模式，`onChatsChange` 接收用户发送新消息后的完整消息数组。

```tsrx demo
../../src/demos/show/chat/basic.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| align | 消息对齐方式 | `'leftRight' \| 'leftAlign'` | `'leftRight'` |
| canSend | 是否允许发送（可用于流式响应期间临时禁用） | boolean | `true` |
| chats | 消息数组，传入即受控 | `ChatMessage[]` | 无 |
| class | 类名 | string | 无 |
| defaultChats | 非受控模式下的默认消息 | `ChatMessage[]` | `[]` |
| hints | 快捷提示文案列表 | string[] | 无 |
| mode | 气泡展示模式 | `'bubble' \| 'noBubble' \| 'userBubble'` | `'bubble'` |
| placeholder | 输入框占位文案 | string | 无 |
| roleConfig | 角色展示配置（如头像、名称） | `ChatRoleConfig` | 无 |
| sendHotKey | 发送快捷键 | `SendHotKey` | 无 |
| style | 自定义样式 | object | 无 |
| onChatsChange | 消息数组变化时的回调 | `(chats) => void` | 无 |
| onHintClick | 点击快捷提示时的回调 | `(hint) => void` | 无 |
| onInputChange | 输入框内容变化时的回调 | `(value) => void` | 无 |
| onMessageCopy | 复制某条消息时的回调 | `(message) => void` | 无 |
| onMessageDelete | 删除某条消息时的回调 | `(message) => void` | 无 |
| onMessageDislike | 点踩某条消息时的回调 | `(message) => void` | 无 |
| onMessageLike | 点赞某条消息时的回调 | `(message) => void` | 无 |
| onMessageSend | 发送消息时的回调，携带发送的文本内容 | `(content: string) => void` | 无 |

## Accessibility

- 消息列表容器、输入框、发送按钮的可访问名称来自 `@lotus/locale`（`Chat.messageList`/`inputLabel`/`sendLabel` 等），随语言切换更新。

## 设计变量

- `--lotus-color-bg-1` / `-fill-0`
- `--lotus-color-text-0` / `-text-1`
- `--lotus-color-primary`
- `--lotus-border-radius-medium`
