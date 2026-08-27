import { track, untrack, effect } from 'ripple';
import { PopconfirmFoundation, type PopconfirmState } from '@lotus/foundation/feedback/popconfirm';
import { Popover, type PopoverProps } from '../../show/popover/index.tsrx';
import { Button, type ButtonType, type ButtonProps } from '../../basic/button/index.tsrx';
import { IconAlertTriangle, IconClose } from '@lotus/icons';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

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
    okText,
    cancelText,
    okType = 'primary',
    cancelType = 'tertiary',
    okButtonProps = {},
    cancelButtonProps = {},
    showCloseIcon = true,
    disabled = false,
    visible: visibleProp,
    defaultVisible = false,
    onConfirm,
    onCancel,
    onVisibleChange,
    position = 'top',
    ...popoverProps
}: PopconfirmProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

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
    // 不像 Popover/Dropdown 只在 Esc 路径归还。监听 displayVisible 本身而非只监听
    // setVisible 调用，是因为点击外部关闭这条路径走的是 Popover 自身的 onVisibleChange
    // 转发（同样最终落到这里的 setVisible），displayVisible 是唯一能覆盖全部关闭路径
    // 的信号源。
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

    // Popconfirm 固定给内部 Popover 传 trigger="custom"，Popover 的 Esc 处理逻辑
    // 里有 `!isControlled` 判断（trigger==="custom" 时 Popover 认为可见性真源在
    // 外部、不该擅自处理 Esc），导致 Popconfirm 无论自己是否受控都完全没有路径
    // 支持 Esc 关闭——这是踩坑记录过的已知缺口，在组件层自己补上，不依赖 Popover
    // 内部对 "custom trigger" 的受控判断（那个判断服务的是 Dropdown/Select 这类
    // 真正需要外部接管开关状态的场景，Popconfirm 只是借用 custom trigger 机制
    // 自己维护开关状态，语义不同）。
    effect(() => {
        if (typeof window === 'undefined') return;
        const handleKeyDown = (event: KeyboardEvent) => {
            if (event.key !== 'Escape') return;
            if (!untrack(() => displayVisible)) return;
            setVisible(false);
        };
        window.addEventListener('keydown', handleKeyDown);
        return () => window.removeEventListener('keydown', handleKeyDown);
    });

    function handleConfirm(event: MouseEvent) {
        foundation.handleConfirm(() => onConfirm?.(event), () => setVisible(false));
    }

    function handleCancel(event: MouseEvent) {
        foundation.handleCancel(() => onCancel?.(event), () => setVisible(false));
    }

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
                @if (showCloseIcon) {
                    <Button
                        class="lotus-popconfirm-close"
                        theme="borderless"
                        type={cancelType}
                        size="small"
                        icon={<IconClose />}
                        aria-label={locale.Popconfirm.close}
                        onClick={handleCancel}
                    />
                }
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
                    {cancelText ?? locale.Popconfirm.cancel}
                </Button>
                <Button
                    theme="solid"
                    type={okType}
                    size="small"
                    loading={confirmLoading}
                    onClick={handleConfirm}
                    {...okButtonProps}
                >
                    {okText ?? locale.Popconfirm.confirm}
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

        .lotus-popconfirm-close {
            flex-shrink: 0;
            margin-inline-start: auto;
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
