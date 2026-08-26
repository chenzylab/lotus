import { track, untrack } from 'ripple';
import { CopyableFoundation, type CopyableState } from '@lotus/foundation/basic/typography';
import { isBackWardPending, type SidebarMode } from '@lotus/foundation/show/sidebar';
import { Container, type ContainerProps } from './container.tsrx';
import { Options, type SidebarOption, type OptionsProps } from './options.tsrx';
import { CodeContent, type CodeItem, type CodeContentProps } from './code-content.tsrx';
import { Annotation, type AnnotationProps, type AnnotationGroup, type AnnotationItem } from './annotation.tsrx';
import { MCPConfigure, type MCPConfigureProps, type MCPOption, type MCPMode } from './mcp-configure.tsrx';
import { FileContent, type FileContentItem, type FileContentProps } from './file-content.tsrx';
import { FileItem, type FileItemProps } from './file-item.tsrx';
import { IconArrowLeft, IconClose } from '@lotus/icons';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

export interface SidebarHeaderProps {
    isMainMode: boolean;
    title?: any;
    detailHeader?: any;
    showClose: boolean;
    onBack: (event: MouseEvent) => void;
    onCancel: (event: MouseEvent) => void;
}

/**
 * Sidebar 详情视图的返回箭头 + 标题头部 + 关闭按钮；对齐 tsrx 组件必须在
 * 渲染块（而非普通函数返回值）里使用 `@if`/JSX 的约束，独立拆成子组件而非
 * 内部函数。作为 `Container.header` 的自定义覆盖值，必须自带关闭按钮——
 * 否则 `showClose` 语义在自定义 header 场景下会静默失效（真机验证阶段发现）。
 */
function SidebarHeader(&{ isMainMode, title, detailHeader, showClose, onBack, onCancel }: SidebarHeaderProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    <>
    <div class="lotus-sidebar-header">
        @if (!isMainMode) {
            <button type="button" class="lotus-sidebar-back" aria-label={locale.Sidebar.back} onClick={onBack}>
                <IconArrowLeft />
            </button>
        }
        @if (detailHeader !== undefined && !isMainMode) {
            <>{detailHeader}</>
        } @else {
            <div class="lotus-sidebar-title">{title}</div>
        }
        @if (showClose) {
            <button type="button" class="lotus-sidebar-close" aria-label={locale.Sidebar.close} onClick={onCancel}>
                <IconClose />
            </button>
        }
    </div>
    </>
}

export { Container, Options, CodeContent, Annotation, MCPConfigure, FileContent, FileItem };
export type {
    ContainerProps,
    OptionsProps,
    CodeContentProps,
    AnnotationProps,
    MCPConfigureProps,
    FileContentProps,
    FileItemProps,
    SidebarOption,
    CodeItem,
    FileContentItem,
    AnnotationGroup,
    AnnotationItem,
    MCPOption,
    MCPMode,
};

export interface SidebarProps extends Omit<ContainerProps, 'children' | 'renderHeader'> {
    mode?: SidebarMode;
    detailContent?: CodeItem | FileContentItem | any;
    activeKey?: string;
    options?: SidebarOption[];
    onActiveOptionChange?: (event: MouseEvent, key: string) => void;
    renderMainContent?: (activeKey: string | undefined) => any;
    renderOptionItem?: (option: SidebarOption, onChange: (key: string) => void) => any;
    renderDetailHeader?: (mode: SidebarMode, detailContent: any) => any;
    renderDetailContent?: (mode: SidebarMode) => any;
    fileEditable?: boolean;
    onFileContentChange?: (content: string) => void;
    onBackWard?: (event: MouseEvent, mode: SidebarMode) => void | Promise<any>;
    onDetailContentCopy?: (event: MouseEvent | undefined, content: string, succeeded: boolean) => void;
}

/**
 * Sidebar：Container 浮层壳 + mode 路由的主视图/详情视图。mode='main' 渲染
 * Options 选项列表，其余 mode（'code'/'file'/自定义）渲染详情视图——
 * `renderDetailContent` 优先级最高，完全接管；否则按 mode 分流到内置的
 * CodeItem/FileItem 详情渲染。`onBackWard` 防重复触发对齐 chenzy.design 的
 * 增强（Semi 源码同步调用不 await，连点可重复触发）。
 */
export function Sidebar(&{
    mode = 'main',
    detailContent,
    activeKey,
    options,
    onActiveOptionChange,
    renderMainContent,
    renderOptionItem,
    renderDetailHeader,
    renderDetailContent,
    fileEditable = true,
    onFileContentChange,
    onBackWard,
    onDetailContentCopy,
    title,
    visible,
    resizable,
    minWidth,
    maxWidth,
    defaultWidth,
    showClose = true,
    onCancel,
    afterVisibleChange,
    class: className,
    style,
}: SidebarProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    let &[copyState] = track<CopyableState>({ copied: false });
    const copyFoundation = new CopyableFoundation({
        getState: () => untrack(() => copyState),
        setState: (patch: Partial<CopyableState>) => { copyState = { ...untrack(() => copyState), ...patch }; },
    });

    let &[backWardStatus] = track<'idle' | 'pending'>('idle');

    function handleBackWard(event: MouseEvent) {
        if (isBackWardPending(untrack(() => backWardStatus))) return;
        const result = onBackWard?.(event, mode);
        if (result && typeof (result as Promise<any>).then === 'function') {
            backWardStatus = 'pending';
            (result as Promise<any>).finally(() => { backWardStatus = 'idle'; });
        }
    }

    function handleDetailCopy(event: MouseEvent) {
        const content = typeof detailContent?.content === 'string' ? detailContent.content : '';
        copyFoundation.copy(content, onDetailContentCopy, event);
    }

    let &[isMainMode] = track<boolean>(() => mode === 'main');
    let &[detailHeaderContent] = track<any>(() => (renderDetailHeader && !isMainMode ? renderDetailHeader(mode, detailContent) : undefined));

    <>
        <Container
            title={title}
            visible={visible}
            resizable={resizable}
            minWidth={minWidth}
            maxWidth={maxWidth}
            defaultWidth={defaultWidth}
            showClose={showClose}
            onCancel={onCancel}
            afterVisibleChange={afterVisibleChange}
            header={<SidebarHeader isMainMode={isMainMode} title={title} detailHeader={detailHeaderContent} showClose={showClose} onBack={handleBackWard} onCancel={(event) => onCancel?.(event)} />}
            class={className}
            style={style}
        >
            @if (renderDetailContent && !isMainMode) {
                <>{renderDetailContent(mode)}</>
            } @else if (isMainMode && renderMainContent) {
                <>{renderMainContent(activeKey)}</>
            } @else if (isMainMode) {
                <Options options={options} activeKey={activeKey} onActiveOptionChange={onActiveOptionChange} renderOptionItem={renderOptionItem} />
            } @else if (mode === 'code') {
                <>
                    <CodeContent codes={detailContent ? [detailContent as CodeItem] : []} />
                    <button type="button" class="lotus-sidebar-copy" onClick={handleDetailCopy}>
                        {copyState.copied ? locale.Typography.copied : locale.Typography.copy}
                    </button>
                </>
            } @else if (mode === 'file') {
                <FileItem content={(detailContent as FileContentItem | undefined)?.content} editable={fileEditable} onContentChange={onFileContentChange} />
            }
        </Container>

        <style>
            .lotus-sidebar-header {
                display: flex;
                align-items: center;
                gap: 8px;
                padding: var(--lotus-spacing-base) var(--lotus-spacing-base-loose);
            }

            .lotus-sidebar-back {
                display: flex;
                align-items: center;
                justify-content: center;
                width: 24px;
                height: 24px;
                border: none;
                background: transparent;
                border-radius: var(--lotus-border-radius-small);
                color: var(--lotus-color-text-2);
                cursor: pointer;
                flex-shrink: 0;
            }

            .lotus-sidebar-back:hover {
                background: var(--lotus-color-fill-0);
                color: var(--lotus-color-text-0);
            }

            .lotus-sidebar-title {
                flex: 1;
                min-width: 0;
                font-size: var(--lotus-font-h5-size);
                font-weight: 600;
                color: var(--lotus-color-text-0);
            }

            .lotus-sidebar-close {
                display: flex;
                align-items: center;
                justify-content: center;
                width: 24px;
                height: 24px;
                border: none;
                background: transparent;
                border-radius: var(--lotus-border-radius-small);
                color: var(--lotus-color-text-2);
                cursor: pointer;
                flex-shrink: 0;
            }

            .lotus-sidebar-close:hover {
                background: var(--lotus-color-fill-0);
                color: var(--lotus-color-text-0);
            }

            .lotus-sidebar-copy {
                margin-top: 8px;
                border: 1px solid var(--lotus-color-border);
                background: var(--lotus-color-bg-0);
                color: var(--lotus-color-text-1);
                border-radius: var(--lotus-border-radius-small);
                padding: 2px 8px;
                font-size: 12px;
                cursor: pointer;
            }
        </style>
    </>
}
