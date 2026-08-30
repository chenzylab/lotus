---
title: AiChatInput AI 输入框
category: 展示类
---

搭配 AiChatDialogue 的富文本输入框。极简 tiptap 文档模型（Document+Paragraph+Text+HardBreak）+ 三个自定义 slot 节点（技能 chip/下拉填空/可编辑填空），不含通用富文本能力（无 StarterKit）。附件上传复用 Upload 组件真实 XHR 流程，MCP 配置出口可联动 Sidebar.MCPConfigure（共享 `MCPOption` 类型）。

## 代码演示

### 如何引入

```tsrx
import { AiChatInput } from '@lotus/ripple';
```

### 基本用法

`onMessageSend` 携带 `inputContents`（`{ type: 'text', text }` 等结构化内容数组），发送快捷键由 `sendHotKey` 控制（`'enter'` 默认 Enter 发送/Shift+Enter 换行）。

```tsrx demo
../../src/demos/show/ai-chat-input/basic.tsrx
```

### 技能触发

`skillHotKey` 指定触发字符（如 `/`），`skills` 定义可选技能列表，选中后 `onSkillChange` 回调。

```tsrx demo
../../src/demos/show/ai-chat-input/skills.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| canSend | 受控的可发送状态；不传则由内容是否为空自动计算 | boolean | 无 |
| class | 类名 | string | 无 |
| extensions | 追加的 tiptap 扩展 | `AnyExtension[]` | 无 |
| generating | 是否处于生成中状态（发送按钮切换为停止按钮） | boolean | `false` |
| getAiChatInputApi | 获取命令式 API（`setContent`/`focusEditor`/`getEditor`） | `(api: AiChatInputApi) => void` | 无 |
| keepSkillAfterSend | 发送后是否保留已选技能 | boolean | `false` |
| mcpOptions | MCP 工具配置选项 | `MCPOption[]` | 无 |
| onConfigureChange | 配置区数值变化时的回调 | `(value: AiInputConfigureValue) => void` | 无 |
| onMcpConfigureClick | 点击 MCP 配置入口的回调 | `() => void` | 无 |
| onMessageSend | 发送消息时的回调 | `(message: AiInputMessageContent) => void` | 无 |
| onReferenceClick | 点击引用项的回调 | `(reference: AiInputReference) => void` | 无 |
| onReferenceDelete | 删除引用项的回调 | `(reference: AiInputReference) => void` | 无 |
| onSkillChange | 技能选中时的回调 | `(skill: AiInputSkill) => void` | 无 |
| onStopGenerate | 生成中点击停止按钮的回调 | `() => void` | 无 |
| onSuggestClick | 点击建议项的回调 | `(suggestion: AiInputSuggestion) => void` | 无 |
| placeholder | 占位文案 | string | 无 |
| references | 引用条目列表，展示在输入框上方 | `AiInputReference[]` | `[]` |
| renderConfigureArea | 自定义配置区渲染（footer 左侧） | `(value, setField) => any` | 无 |
| renderReference | 自定义引用条目渲染 | `(reference) => any` | 无 |
| renderSkillItem | 自定义技能选项渲染 | `(args: { skill, onClick }) => any` | 无 |
| renderSuggestionItem | 自定义建议项渲染 | `(args: { suggestion, index, active }) => any` | 无 |
| renderTemplate | 自定义技能模板面板渲染 | `(skill, onTemplateClick) => any` | 无 |
| sendHotKey | 发送快捷键 | `'enter' \| 'shift+enter'` | `'enter'` |
| showReference | 是否展示引用条 | boolean | 无 |
| showTemplateButton | 是否展示技能模板按钮 | boolean | `false` |
| showUploadButton | 是否展示上传按钮 | boolean | 无 |
| skillHotKey | 触发技能面板的字符 | string | 无 |
| skills | 可选技能列表 | `AiInputSkill[]` | 无 |
| style | 自定义样式 | object | 无 |
| suggestions | 建议列表（空内容时展示） | `AiInputSuggestion[]` | 无 |
| uploadProps | 透传给内部 `Upload` 组件的配置 | `UploadProps` | 无 |

## Accessibility

- 技能面板、建议面板均携带 `role="listbox"`，选项携带 `role="option"`（建议面板额外携带 `aria-selected` 反映当前高亮项）。
- 引用条、附件列表均携带 `role="list"`/`role="listitem"`，删除按钮的可访问名称来自 `@lotus/locale`（`AiChatInput.removeReference`/`removeAttachment`），随语言切换更新。
- 发送按钮的可访问名称来自 `@lotus/locale` 的 `AiChatInput.send`。

## 设计变量

- `--lotus-color-bg-0` / `-bg-1`
- `--lotus-color-text-0` / `-text-1` / `-text-2`
- `--lotus-color-border`
- `--lotus-color-primary`
- `--lotus-border-radius-medium`
