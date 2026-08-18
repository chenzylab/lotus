import { track } from 'ripple';

export interface CollapsibleProps {
    isOpen?: boolean;
    children?: any;
    duration?: number;
    motion?: boolean;
    keepDOM?: boolean;
    collapseHeight?: number;
    style?: Record<string, any>;
    class?: string;
    id?: string;
    'aria-label'?: string;
}

/**
 * 无头（headless）展开/收起动画容器，对齐 Semi Design 的 Collapsible：
 * isOpen 完全受控，没有 header/itemKey/多面板状态机，触发器由使用方
 * 自己写（如一个普通 Button + 外部 track() 状态）。与 Collapse 的区别是
 * Collapse = "多个带 header 的 Panel + 手风琴/多选状态机"，Collapsible =
 * "单个裸的展开收起动画壳子，可包任意内容"。用 CSS max-height transition
 * 实现动画（对齐 Collapse/Nav SubNav 的既有轻量方案），不引入 Semi 那套
 * ResizeObserver 精确测高。
 */
export function Collapsible(&{
    isOpen = false,
    children,
    duration = 250,
    motion = true,
    keepDOM = false,
    collapseHeight = 0,
    style,
    class: className,
    id,
    'aria-label': ariaLabel,
}: CollapsibleProps) @{
    let &[shouldRenderChildren] = track<boolean>(() => isOpen || keepDOM);

    <>
        <div
            id={id}
            class={['lotus-collapsible', isOpen ? 'lotus-collapsible-open' : ''].filter(Boolean).join(' ')}
            style={{
                ...style,
                maxHeight: isOpen ? '2000px' : `${collapseHeight}px`,
                transitionDuration: motion ? `${duration}ms` : '0ms',
            }}
            aria-hidden={!isOpen}
            aria-label={ariaLabel}
        >
            @if (shouldRenderChildren) {
                <div class={['lotus-collapsible-inner', className ?? ''].filter(Boolean).join(' ')}>
                    {children}
                </div>
            }
        </div>

        <style>
            .lotus-collapsible {
                overflow: hidden;
                transition-property: max-height;
                transition-timing-function: ease;
            }
        </style>
    </>
}
