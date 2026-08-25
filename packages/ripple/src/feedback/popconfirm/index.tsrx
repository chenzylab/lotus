import { track, untrack, effect } from 'ripple';
import { PopconfirmFoundation, type PopconfirmState } from '@lotus/foundation/feedback/popconfirm';
import { Popover, type PopoverProps } from '../../show/popover/index.tsrx';
import { Button, type ButtonType, type ButtonProps } from '../../basic/button/index.tsrx';
import { IconAlertTriangle } from '@lotus/icons';

export interface PopconfirmProps extends Omit<PopoverProps, 'content' | 'trigger' | 'visible'> {
    children?: any;
    title?: any;
    description?: any;
    icon?: any;
    okText?: string;
    cancelText?: string;
    okType?: ButtonType;
    cancelType?: ButtonType;
    okButtonProps?: ButtonProps;
    cancelButtonProps?: ButtonProps;
    showCloseIcon?: boolean;
    disabled?: boolean;
    visible?: boolean;
    defaultVisible?: boolean;
    onConfirm?: (event: MouseEvent) => Promise<any> | void;
    onCancel?: (event: MouseEvent) => Promise<any> | void;
    onVisibleChange?: (visible: boolean) => void;
}

/**
 * Popconfirm：组合已验证的 Popover 实现（trigger="custom" 完全自己接管
 * 开关状态），不重新实现浮层定位——只封装"title+description+footer 按钮"
 * 的内容结构与确认/取消的 Promise-aware loading 状态机。
 */
export function Popconfirm(&{
    children,
    title,
    description,
    icon,
    okText = '确定',
    cancelText = '取消',
    okType = 'primary',
    cancelType = 'tertiary',
    okButtonProps = {},
    cancelButtonProps = {},
    disabled = false,
    visible: visibleProp,
    defaultVisible = false,
    onConfirm,
    onCancel,
    onVisibleChange,
    position = 'top',
    ...popoverProps
}: PopconfirmProps) @{
    const isControlled = visibleProp !== undefined;
    let &[state] = track<PopconfirmState>({
        visible: isControlled ? !!visibleProp : defaultVisible,
        confirmLoading: false,
        cancelLoading: false,
    });

    const foundation = new PopconfirmFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<PopconfirmState>) => { state = { ...untrack(() => state), ...patch }; },
    });

    let &[displayVisible] = track<boolean>(() => (isControlled ? !!visibleProp : state.visible));
    let prevFocusElement: HTMLElement | null = null;

    // 焦点归还对齐 Semi PopconfirmFoundation.handleVisibleChange(false) 的设计——在所有
    // 关闭路径统一归还（确认/取消/点击外部/Esc），是 Tooltip 系组件里唯一全路径都归还的，
    // 不像 Popover/Dropdown 只在 Esc 路径归还。这里监听 displayVisible 本身而非包一层
    // setVisible，因为 handleConfirm/handleCancel 在非受控模式下直接改 Foundation state、
    // 不经过 setVisible，只有监听 displayVisible 才能覆盖全部关闭路径。
    effect(() => {
        if (displayVisible) {
            prevFocusElement = untrack(() => document.activeElement instanceof HTMLElement ? document.activeElement : null);
        } else {
            untrack(() => prevFocusElement)?.focus({ preventScroll: true });
        }
    });

    function setVisible(next: boolean) {
        if (!isControlled) state = { ...untrack(() => state), visible: next };
        onVisibleChange?.(next);
    }

    function handleTriggerClick() {
        if (disabled) return;
        setVisible(!untrack(() => displayVisible));
    }

    function handleConfirm(event: MouseEvent) {
        foundation.handleConfirm(() => onConfirm?.(event));
    }

    function handleCancel(event: MouseEvent) {
        foundation.handleCancel(() => onCancel?.(event));
    }

    // handleConfirm/handleCancel 内部通过 foundation.setState 把 visible 写回 state，
    // 但 isControlled 模式下外部才是 visible 的真源；这里用 effect 风格的桥接：
    // 非受控模式下 state.visible 变化直接生效；受控模式下仅同步通知，不覆盖 state。
    let &[confirmLoading] = track<boolean>(() => state.confirmLoading);
    let &[cancelLoading] = track<boolean>(() => state.cancelLoading);

    let &[content] = track(() => (
        <div class="lotus-popconfirm-content">
            <div class="lotus-popconfirm-header">
                @if (icon !== null) {
                    <span class="lotus-popconfirm-icon">{icon ?? <IconAlertTriangle />}</span>
                }
                <div class="lotus-popconfirm-body">
                    @if (title) {
                        <div class="lotus-popconfirm-title">{title}</div>
                    }
                    @if (description) {
                        <div class="lotus-popconfirm-description">{description}</div>
                    }
                </div>
            </div>
            <div class="lotus-popconfirm-footer">
                <Button
                    theme="borderless"
                    type={cancelType}
                    size="small"
                    loading={cancelLoading}
                    onClick={handleCancel}
                    {...cancelButtonProps}
                >
                    {cancelText}
                </Button>
                <Button
                    theme="solid"
                    type={okType}
                    size="small"
                    loading={confirmLoading}
                    onClick={handleConfirm}
                    {...okButtonProps}
                >
                    {okText}
                </Button>
            </div>
        </div>
    ));

    <>
        <Popover
            {...popoverProps}
            position={position}
            trigger="custom"
            visible={displayVisible}
            content={content}
            class="lotus-popconfirm-popover"
            onVisibleChange={setVisible}
        >
            <span onClick={handleTriggerClick}>{children}</span>
        </Popover>

    <style>
        .lotus-popconfirm-content {
            display: flex;
            flex-direction: column;
            gap: var(--lotus-spacing-tight);
            min-width: 200px;
            max-width: 320px;
        }

        .lotus-popconfirm-header {
            display: flex;
            align-items: flex-start;
            gap: 6px;
        }

        .lotus-popconfirm-icon {
            display: flex;
            align-items: center;
            flex-shrink: 0;
            margin-top: 2px;
            color: var(--lotus-color-warning);
        }

        .lotus-popconfirm-body {
            display: flex;
            flex-direction: column;
            gap: 2px;
            min-width: 0;
        }

        .lotus-popconfirm-title {
            font-size: var(--lotus-font-body-size);
            font-weight: var(--lotus-font-weight-semibold);
            color: var(--lotus-color-text-0);
        }

        .lotus-popconfirm-description {
            font-size: var(--lotus-font-label-size);
            color: var(--lotus-color-text-1);
        }

        .lotus-popconfirm-footer {
            display: flex;
            justify-content: flex-end;
            gap: 6px;
        }
        </style>
    </>
}
