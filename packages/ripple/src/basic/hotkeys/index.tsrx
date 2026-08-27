import { track, effect, untrack } from 'ripple';
import { matchHotKeys, isValidHotKeys, Keys, type HotKey, type MatchHotKeysOptions } from '@lotus/foundation/basic/hotkeys';

export { Keys };
export type { HotKey };

export interface HotKeysProps {
    /** 快捷键组合：恰好 1 个普通键 + 0~多个修饰键（对齐 Semi hotKeys 数组语法，非 'ctrl+s' 字符串）。 */
    hotKeys: HotKey[];
    /** 键位提示文案；不传则回退用 hotKeys 本身渲染。 */
    content?: string[];
    preventDefault?: boolean;
    onClick?: () => void;
    onHotKey?: (event: KeyboardEvent) => void;
    /** 死 prop：见 Foundation 层文件头注释，声明了但不改变匹配逻辑（严格对齐 Semi）。 */
    mergeMetaCtrl?: boolean;
    /** 自定义渲染内容；传 null 或返回 null 时不渲染任何节点（对齐 Semi render 语义）。 */
    render?: (() => any) | any;
    /** 监听目标，默认 document.body（对齐 Semi）。 */
    getListenerTarget?: () => HTMLElement;
    /** 传了 onClick 时这个提示徽标会带 role="button"，需要一个可访问名称。 */
    'aria-label'?: string;
    class?: string;
    style?: Record<string, any>;
}

/**
 * HotKeys：快捷键组合监听 + 可选键位提示 UI。对齐 Semi Design hotKeys
 * （Plus 分类）——匹配算法（修饰键精确比较 + code 优先/key 回退）在
 * `packages/foundation/src/basic/hotkeys/foundation.ts` 里以纯函数实现，
 * 无状态（不维护"当前按下按键集合"，每次 keydown 独立判断），因此本组件
 * 不需要 Foundation<S> 状态机，只在 effect() 里编排事件监听的生命周期。
 */
export function HotKeys(&{
    hotKeys,
    content,
    preventDefault = false,
    onClick,
    onHotKey,
    mergeMetaCtrl = false,
    render,
    getListenerTarget,
    'aria-label': ariaLabel,
    class: className,
    style,
}: HotKeysProps) @{
    isValidHotKeys(hotKeys);

    effect(() => {
        const target = getListenerTarget ? getListenerTarget() : document.body;
        const options: MatchHotKeysOptions = { mergeMetaCtrl };
        function handleKeyDown(event: KeyboardEvent) {
            if (!matchHotKeys(event, hotKeys, options)) return;
            if (preventDefault) event.preventDefault();
            onHotKey?.(event);
        }
        target.addEventListener('keydown', handleKeyDown);
        return () => target.removeEventListener('keydown', handleKeyDown);
    });

    let &[renderedContent] = track<any[] | null>(() => {
        if (render !== undefined) {
            const resolved = typeof render === 'function' ? render() : render;
            return resolved === null ? null : [resolved];
        }
        return content ?? hotKeys;
    });

    function handleContentKeyDown(event: KeyboardEvent) {
        if (!onClick) return;
        if (event.key !== 'Enter' && event.key !== ' ') return;
        event.preventDefault();
        onClick();
    }

    @if (renderedContent !== null) {
        <>
        <div
            class={['lotus-hotkeys', className ?? ''].filter(Boolean).join(' ')}
            style={style}
            role={onClick ? 'button' : undefined}
            tabIndex={onClick ? 0 : undefined}
            aria-label={onClick ? ariaLabel : undefined}
            onClick={onClick}
            onKeyDown={handleContentKeyDown}
        >
            @if (render !== undefined) {
                {renderedContent[0]}
            } @else {
                <>
                    @for (const key of renderedContent; index i) {
                        <span>
                            @if (i > 0) {
                                <span class="lotus-hotkeys-split">+</span>
                            }
                            <span class="lotus-hotkeys-content">{key}</span>
                        </span>
                    }
                </>
            }
        </div>

        <style>
            .lotus-hotkeys {
                display: inline-flex;
                align-items: center;
                gap: 2px;
                font-size: 12px;
                color: var(--lotus-color-text-1);
            }

            .lotus-hotkeys :global(.lotus-hotkeys-content) {
                display: inline-block;
                padding: 1px 6px;
                border-radius: var(--lotus-border-radius-small);
                background: var(--lotus-color-fill-1);
                border: 1px solid var(--lotus-color-border);
                font-family: ui-monospace, 'SFMono-Regular', 'SF Mono', Menlo, Monaco, Consolas, monospace;
                text-transform: uppercase;
            }

            .lotus-hotkeys :global(.lotus-hotkeys-split) {
                margin: 0 2px;
                color: var(--lotus-color-text-3);
            }
        </style>
        </>
    }
}
