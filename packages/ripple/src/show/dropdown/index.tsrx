import { Popover } from '../popover/index.tsrx';
import type { FloatingPosition } from '@lotus/foundation/base/floating-position';
import type { TooltipTrigger } from '@lotus/foundation/show/tooltip';

export interface DropdownProps {
    children?: any;
    /** 弹出层内容，一般由 DropdownMenu + DropdownItem/DropdownTitle/DropdownDivider 组成。 */
    render?: any;
    position?: FloatingPosition;
    trigger?: TooltipTrigger;
    visible?: boolean;
    spacing?: number;
    closeOnEsc?: boolean;
    autoAdjustOverflow?: boolean;
    getPopupContainer?: () => HTMLElement | null;
    zIndex?: number;
    style?: Record<string, any>;
    class?: string;
    onVisibleChange?: (visible: boolean) => void;
}

/**
 * Dropdown 复用 Popover 的浮层定位/触发能力，只是把内容语义从"任意提示内容"收窄为
 * "菜单"，配合 DropdownMenu/DropdownItem 使用。lotus 版本只支持这个组合式用法——
 * Semi 的 `menu` prop（传 JSON Array 快速配置）不是核心能力，且与本次 Nav 综合 demo
 * 无关，未实现；如需数组配置菜单，先用 `.map()` 生成 DropdownItem 数组再传入 render。
 */
export function Dropdown({
    children,
    render,
    position = 'bottom',
    trigger = 'hover',
    visible,
    spacing,
    closeOnEsc = true,
    autoAdjustOverflow = true,
    getPopupContainer,
    zIndex = 1050,
    style,
    class: className,
    onVisibleChange,
}: DropdownProps) @{
    <>
        <Popover
            content={render}
            position={position}
            trigger={trigger}
            visible={visible}
            spacing={spacing}
            closeOnEsc={closeOnEsc}
            autoAdjustOverflow={autoAdjustOverflow}
            getPopupContainer={getPopupContainer}
            zIndex={zIndex}
            style={style}
            class={['lotus-dropdown', className ?? ''].filter(Boolean).join(' ')}
            onVisibleChange={onVisibleChange}
        >
            {children}
        </Popover>

        <style>
            /* Dropdown 的内容是菜单列表，DropdownMenu 自己有 padding，覆盖 Popover 默认的
               .lotus-popover-content padding，避免双重内边距。 */
            .lotus-dropdown .lotus-popover-content {
                padding: 0;
            }
        </style>
    </>
}
