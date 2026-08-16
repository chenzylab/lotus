import { track } from 'ripple';
import { CopyableFoundation, EllipsisFoundation, type CopyableState, type EllipsisState, type EllipsisConfig } from '@lotus/foundation/basic/typography';
import { IconCopy, IconTick } from '@lotus/icons';

export type TypographyType = 'primary' | 'secondary' | 'tertiary' | 'quaternary' | 'warning' | 'danger' | 'success';
export type TypographySize = 'normal' | 'small' | 'inherit';
export type TypographyWeight = 'light' | 'regular' | 'medium' | 'semibold' | 'bold' | 'default';

export interface TypographyLinkConfig {
    href?: string;
    target?: string;
    [key: string]: any;
}

export interface TypographyCopyableConfig {
    content?: string;
    copyTip?: any;
    successTip?: any;
    icon?: any;
    render?: (copied: boolean, doCopy: (event: MouseEvent) => void) => any;
    onCopy?: (event: MouseEvent | undefined, content: string, succeeded: boolean) => void;
}

export type { EllipsisConfig } from '@lotus/foundation/basic/typography';

export interface TypographySharedProps {
    type?: TypographyType;
    disabled?: boolean;
    mark?: boolean;
    code?: boolean;
    delete?: boolean;
    underline?: boolean;
    strong?: boolean;
    link?: boolean | TypographyLinkConfig;
    icon?: any;
    copyable?: boolean | TypographyCopyableConfig;
    ellipsis?: boolean | EllipsisConfig;
    style?: Record<string, any>;
    class?: string;
}

/** 拼接三个子组件共享的视觉修饰 class（type/disabled/mark/delete/underline/strong/link）。 */
export function sharedClasses(props: TypographySharedProps, extra: string[] = []): string {
    return [
        'lotus-typography',
        `lotus-typography-${props.type ?? 'primary'}`,
        props.disabled ? 'lotus-typography-disabled' : '',
        props.mark ? 'lotus-typography-mark' : '',
        props.delete ? 'lotus-typography-delete' : '',
        props.underline ? 'lotus-typography-underline' : '',
        props.strong ? 'lotus-typography-strong' : '',
        props.link ? 'lotus-typography-link' : '',
        ...extra,
        props.class ?? '',
    ]
        .filter(Boolean)
        .join(' ');
}

export function weightStyle(weight?: TypographyWeight): Record<string, any> {
    if (!weight || weight === 'default') return {};
    return { fontWeight: `var(--lotus-font-weight-${weight})` };
}

/** 可复制按钮：封装状态机（copied 短暂高亮）+ 剪贴板写入，三个子组件共享同一份实现。
 * `nodeRef` 可选——挂载 JS 精确截断（`measureEllipsisText`）时需要拿到按钮节点一并计入可用宽高。 */
export function CopyableAction(&{ config, textContent, nodeRef }: { config: TypographyCopyableConfig; textContent: string; nodeRef?: (node: HTMLElement) => void }) @{
    let &[state] = track<CopyableState>({ copied: false });
    const foundation = new CopyableFoundation({
        getState: () => state,
        setState: (patch: Partial<CopyableState>) => { state = { ...state, ...patch }; },
    });

    let resetTimer: ReturnType<typeof setTimeout> | undefined;

    const doCopy = async (event: MouseEvent) => {
        event.stopPropagation();
        const content = config.content ?? textContent;
        await foundation.copy(content, config.onCopy, event);
        if (resetTimer) clearTimeout(resetTimer);
        resetTimer = setTimeout(() => foundation.reset(), 2000);
    };

    @if (config.render) {
        <>{config.render(state.copied, doCopy)}</>
    } @else {
        <button
            type="button"
            class="lotus-typography-copy"
            aria-label={state.copied ? '已复制' : '复制'}
            onClick={doCopy}
            ref={nodeRef}
        >
            @if (config.icon) {
                <>{config.icon}</>
            } @else {
                @if (state.copied) {
                    <IconTick />
                } @else {
                    <IconCopy />
                }
            }
        </button>
    }
}

export function resolveEllipsisConfig(ellipsis: boolean | EllipsisConfig | undefined): EllipsisConfig | null {
    if (!ellipsis) return null;
    return typeof ellipsis === 'object' ? ellipsis : {};
}

export function resolveCopyableConfig(copyable: boolean | TypographyCopyableConfig | undefined): TypographyCopyableConfig | null {
    if (!copyable) return null;
    return typeof copyable === 'object' ? copyable : {};
}

export function resolveLinkConfig(link: boolean | TypographyLinkConfig | undefined): TypographyLinkConfig | null {
    if (!link) return null;
    return typeof link === 'object' ? link : {};
}

export { EllipsisFoundation };
export type { CopyableState, EllipsisState };
