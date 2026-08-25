import { track, untrack } from 'ripple';
import { Editor, type JSONContent, type AnyExtension } from '@tiptap/core';
import {
    AiChatInputFoundation,
    initialAiChatInputState,
    resolveCanSend,
    getSkillSlotHTML,
    type AiChatInputState,
    type AiInputAttachment,
    type AiInputReference,
    type AiInputMessageContent,
    type AiInputSendHotKey,
    type AiInputSuggestion,
    type AiInputSkill,
    type AiInputConfigureValue,
    type MCPOption,
} from '@lotus/foundation/show/ai-chat-input';
import { AiInputEditor } from './editor.tsrx';
import { ReferenceBar } from './reference-bar.tsrx';
import { AttachmentList } from './attachment-list.tsrx';
import { Popover } from '../popover/index.tsrx';
import { SuggestionPanel } from './suggestion-panel.tsrx';
import { SkillPanel } from './skill-panel.tsrx';
import { TemplatePanel } from './template-panel.tsrx';
import { ConfigureMcp } from './configure-mcp.tsrx';
import { Upload, type UploadProps, type FileItem } from '../../input/upload/index.tsrx';
import { Button } from '../../basic/button/index.tsrx';
import { IconSend, IconStop } from '@lotus/icons';

export * from '@lotus/foundation/show/ai-chat-input';
export type { UploadProps };

export interface AiChatInputApi {
    setContent: (content: string) => void;
    focusEditor: () => void;
    getEditor: () => Editor | null;
}

export interface AiChatInputProps {
    placeholder?: string;
    sendHotKey?: AiInputSendHotKey;
    canSend?: boolean;
    generating?: boolean;
    references?: AiInputReference[];
    renderReference?: (reference: AiInputReference) => any;
    onReferenceDelete?: (reference: AiInputReference) => void;
    onReferenceClick?: (reference: AiInputReference) => void;
    showReference?: boolean;
    uploadProps?: UploadProps;
    showUploadButton?: boolean;
    suggestions?: AiInputSuggestion[];
    renderSuggestionItem?: (args: { suggestion: AiInputSuggestion; index: number; active: boolean }) => any;
    onSuggestClick?: (suggestion: AiInputSuggestion) => void;
    skills?: AiInputSkill[];
    skillHotKey?: string;
    renderSkillItem?: (args: { skill: AiInputSkill; onClick: () => void }) => any;
    onSkillChange?: (skill: AiInputSkill) => void;
    renderTemplate?: (skill: AiInputSkill, onTemplateClick: (content: string) => void) => any;
    showTemplateButton?: boolean;
    mcpOptions?: MCPOption[];
    onConfigureChange?: (value: AiInputConfigureValue) => void;
    onMcpConfigureClick?: () => void;
    /** 自定义配置区渲染（Configure.Select/Button/RadioButton 场景）：收到当前 configureValue + 单字段更新函数，返回任意 JSX 插入 footer 左侧配置区。 */
    renderConfigureArea?: (value: AiInputConfigureValue, setField: (field: string, value: unknown) => void) => any;
    keepSkillAfterSend?: boolean;
    onMessageSend?: (message: AiInputMessageContent) => void;
    onStopGenerate?: () => void;
    extensions?: AnyExtension[];
    getAiChatInputApi?: (api: AiChatInputApi) => void;
    class?: string;
    style?: Record<string, any>;
}

let attachmentUidCounter = 0;
function nextAttachmentUid(): string {
    attachmentUidCounter += 1;
    return `lotus-ai-input-attachment-${attachmentUidCounter}`;
}

function fileItemToAttachment(file: FileItem, uid: string): AiInputAttachment {
    return { uid, name: file.name, status: file.status, size: file.size, url: file.url, fileInstance: file.fileInstance, percent: file.percent };
}

/**
 * AiChatInput：搭配 AiChatDialogue 的富文本输入框。极简 tiptap 文档模型
 * （Document+Paragraph+Text+HardBreak）+ 三个自定义 slot 节点（技能 chip/
 * 下拉填空/可编辑填空），不含通用富文本能力（无 StarterKit）。附件上传复用
 * Upload 组件真实 XHR 流程，MCP 配置出口联动 Sidebar.MCPConfigure（共享
 * MCPOption 类型）。命令式 API 通过 getAiChatInputApi 回调交出。
 */
export function AiChatInput(&{
    placeholder = '输入消息...',
    sendHotKey = 'enter',
    canSend: canSendProp,
    generating = false,
    references = [],
    renderReference,
    onReferenceDelete,
    onReferenceClick,
    showReference = true,
    uploadProps,
    showUploadButton = true,
    suggestions = [],
    renderSuggestionItem,
    onSuggestClick,
    skills = [],
    skillHotKey,
    renderSkillItem,
    onSkillChange,
    renderTemplate,
    showTemplateButton = false,
    mcpOptions,
    onConfigureChange,
    onMcpConfigureClick,
    renderConfigureArea,
    keepSkillAfterSend = false,
    onMessageSend,
    onStopGenerate,
    extensions = [],
    getAiChatInputApi,
    class: className,
    style,
}: AiChatInputProps) @{
    let &[state] = track<AiChatInputState>(() => initialAiChatInputState());

    const foundation = new AiChatInputFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<AiChatInputState>) => { state = { ...untrack(() => state), ...patch }; },
    });

    let editorInstance: Editor | null = null;
    let &[suggestionVisible] = track<boolean>(false);
    let blurHideTimer: ReturnType<typeof setTimeout> | null = null;

    function handleContentChange(json: JSONContent, html: string) {
        const inputContents = foundation.handleContentChange(json, html);
        if (inputContents.length > 0) suggestionVisible = false;
    }

    function handleSend() {
        const canSend = foundation.resolveCanSend(canSendProp);
        if (!canSend) return;
        const message = foundation.handleSend(keepSkillAfterSend);
        onMessageSend?.(message);
        editorInstance?.commands.clearContent();
    }

    function handleEditorFocus() {
        if (blurHideTimer) { clearTimeout(blurHideTimer); blurHideTimer = null; }
        if (untrack(() => state).inputContents.length === 0) suggestionVisible = true;
    }

    function handleEditorBlur() {
        // 延迟隐藏：给"点击建议项"这类需要先在浮层内 mousedown 的交互留出时间，
        // 否则 blur 立即隐藏浮层会导致点击目标消失，click 事件永远打不到建议项上。
        blurHideTimer = setTimeout(() => { suggestionVisible = false; }, 150);
    }

    function handleSuggestClick(suggestion: AiInputSuggestion) {
        onSuggestClick?.(suggestion);
        foundation.setSuggestionVisible(false);
        suggestionVisible = false;
    }

    function handleOpenSkillPanel() {
        foundation.setSkillPanelVisible(true);
    }

    function handleSkillClick(skill: AiInputSkill) {
        foundation.selectSkill(skill);
        editorInstance?.chain().focus().insertContent(getSkillSlotHTML(skill)).run();
        onSkillChange?.(skill);
    }

    function handleTemplateClick(content: string) {
        editorInstance?.commands.insertContent(content);
        foundation.setTemplateVisible(false);
    }

    function handleUploadChange(fileList: FileItem[]) {
        const { attachments } = untrack(() => state);
        const knownUids = new Map(attachments.map((a) => [a.name, a.uid]));
        const next = fileList.map((file) => fileItemToAttachment(file, knownUids.get(file.name) ?? nextAttachmentUid()));
        state = { ...untrack(() => state), attachments: next };
    }

    function handleAttachmentRemove(attachment: AiInputAttachment) {
        if (attachment.uid) foundation.removeAttachment(attachment.uid);
    }

    function handleConfigureFieldChange(field: string, value: unknown) {
        const next = foundation.updateConfigureField(field, value);
        onConfigureChange?.(next);
    }

    getAiChatInputApi?.({
        setContent: (content: string) => editorInstance?.commands.setContent(content),
        focusEditor: () => editorInstance?.commands.focus(),
        getEditor: () => editorInstance,
    });

    let &[canSendComputed] = track<boolean>(() => resolveCanSend({ canSend: canSendProp, isEmpty: state.inputContents.length === 0, attachments: state.attachments }));

    <>
        <div class={['lotus-ai-chat-input', className ?? ''].filter(Boolean).join(' ')} style={style}>
            @if (showReference && references.length > 0) {
                <ReferenceBar references={references} renderReference={renderReference} onReferenceDelete={onReferenceDelete} onReferenceClick={onReferenceClick} />
            }

            @if (state.attachments.length > 0) {
                <AttachmentList attachments={state.attachments} onRemove={handleAttachmentRemove} />
            }

            <Popover trigger="custom" visible={suggestionVisible && suggestions.length > 0} position="top" content={
                <SuggestionPanel suggestions={suggestions} activeIndex={state.suggestionActiveIndex} renderSuggestionItem={renderSuggestionItem} onSuggestClick={handleSuggestClick} />
            }>
                <Popover trigger="custom" visible={state.skillPanelVisible} position="top" content={
                    <SkillPanel skills={skills} renderSkillItem={renderSkillItem} onSkillClick={handleSkillClick} />
                }>
                    <AiInputEditor
                        placeholder={placeholder}
                        sendHotKey={sendHotKey}
                        skillHotKey={skillHotKey}
                        skillCount={skills.length}
                        extensions={extensions}
                        onContentChange={handleContentChange}
                        onSend={handleSend}
                        onOpenSkillPanel={handleOpenSkillPanel}
                        onFocus={handleEditorFocus}
                        onBlur={handleEditorBlur}
                        getEditorApi={(e: Editor) => { editorInstance = e; }}
                    />
                </Popover>
            </Popover>

            @if (showTemplateButton && state.currentSkill?.hasTemplate && renderTemplate) {
                <Popover trigger="custom" visible={state.templateVisible} position="top" content={
                    <TemplatePanel skill={state.currentSkill} renderTemplate={renderTemplate} onTemplateClick={handleTemplateClick} />
                }>
                    <button type="button" class="lotus-ai-chat-input-template-trigger" onClick={() => foundation.setTemplateVisible(!state.templateVisible)}>
                        模版
                    </button>
                </Popover>
            }

            <div class="lotus-ai-chat-input-footer">
                <div class="lotus-ai-chat-input-configure">
                    @if (showUploadButton && uploadProps) {
                        <Upload {...uploadProps} listType="none" onChange={handleUploadChange} />
                    }
                    @if (mcpOptions) {
                        <ConfigureMcp options={mcpOptions} onConfigureButtonClick={onMcpConfigureClick} />
                    }
                    @if (renderConfigureArea) {
                        <>{renderConfigureArea(state.configureValue, handleConfigureFieldChange)}</>
                    }
                </div>
                <div class="lotus-ai-chat-input-actions">
                    @if (generating) {
                        <Button theme="light" icon={<IconStop />} onClick={() => onStopGenerate?.()}>停止生成</Button>
                    } @else {
                        <Button theme="solid" icon={<IconSend />} disabled={!canSendComputed} onClick={handleSend} aria-label="发送">发送</Button>
                    }
                </div>
            </div>
        </div>

        <style>
            .lotus-ai-chat-input {
                display: flex;
                flex-direction: column;
                border: 1px solid var(--lotus-color-border);
                border-radius: var(--lotus-border-radius-medium);
                padding: 12px;
                background: var(--lotus-color-bg-1);
            }

            /* Popover 的 trigger span 默认 inline-block（收缩到内容宽度），
               这里包裹的编辑器是需要撑满整行的 block 级元素，两者宽度计算
               互相依赖会塌陷为 0——显式撑满宽度打破这个循环。 */
            .lotus-ai-chat-input :global(.lotus-popover-trigger) {
                display: block;
                width: 100%;
            }

            .lotus-ai-chat-input-template-trigger {
                align-self: flex-start;
                border: 1px solid var(--lotus-color-border);
                background: var(--lotus-color-bg-0);
                color: var(--lotus-color-primary);
                border-radius: var(--lotus-border-radius-small);
                padding: 2px 8px;
                font-size: 12px;
                cursor: pointer;
                margin-top: 8px;
            }

            .lotus-ai-chat-input-footer {
                display: flex;
                align-items: center;
                justify-content: space-between;
                margin-top: 12px;
            }

            .lotus-ai-chat-input-configure {
                display: flex;
                align-items: center;
                gap: 8px;
            }

            .lotus-ai-chat-input-actions {
                display: flex;
                align-items: center;
                gap: 8px;
            }
        </style>
    </>
}
