import { track } from 'ripple';
import { resolveSteps, type StepItemInput, type StepStatus, type StepsDirection, type StepsSize } from '@lotus/foundation/navigation/steps';
import { IconTickCircle, IconAlertCircle, IconAlertTriangle } from '@lotus/icons';

export type { StepStatus, StepsDirection, StepsSize, StepItemInput };
export type StepsType = 'basic' | 'fill';

export interface StepsProps {
    items: StepItemInput[];
    type?: StepsType;
    current?: number;
    defaultCurrent?: number;
    initial?: number;
    status?: StepStatus;
    direction?: StepsDirection;
    size?: StepsSize;
    hasLine?: boolean;
    onChange?: (current: number) => void;
    style?: Record<string, any>;
    class?: string;
    'aria-label'?: string;
}

function StatusIcon(&{ status, stepNumber }: { status: StepStatus; stepNumber: number }) {
    if (status === 'error') return <IconAlertCircle />;
    if (status === 'finish') return <IconTickCircle />;
    if (status === 'warning') return <IconAlertTriangle />;
    return <span class="lotus-steps-item-number">{stepNumber + 1}</span>;
}

/**
 * Steps：basic/fill 两种视觉变体共享同一套状态计算逻辑（resolveSteps
 * 纯函数，Foundation 层），仅 CSS 呈现不同——对齐 Semi 的 BasicStep/
 * FillStep 图标映射规则相同、仅样式差异这一事实。`nav`（可点击导航式，
 * 与 Tabs 高度重叠）变体本期不做。Ripple 无 React.cloneElement，
 * 用 items 数组 + 统一渲染取代 children 组合（同 ButtonGroup 先例）。
 */
export function Steps(&{
    items,
    type = 'fill',
    current: currentProp,
    defaultCurrent = 0,
    initial = 0,
    status = 'process',
    direction = 'horizontal',
    size = 'default',
    hasLine = true,
    onChange,
    style,
    class: className,
    'aria-label': ariaLabel,
}: StepsProps) @{
    const isControlled = currentProp !== undefined;
    let &[state] = track<number>(defaultCurrent);
    let &[displayCurrent] = track<number>(() => (isControlled ? currentProp! : state));

    let &[resolved] = track(() => resolveSteps(items, displayCurrent, status, initial));

    function handleClick(step: ReturnType<typeof resolveSteps>[number]) {
        if (step.disabled) return;
        if (!isControlled) state = step.stepNumber;
        onChange?.(step.stepNumber);
    }

    let &[classes] = track<string>(() =>
        [
            'lotus-steps',
            `lotus-steps-${type}`,
            `lotus-steps-${direction}`,
            size !== 'default' ? `lotus-steps-${size}` : '',
            hasLine ? 'lotus-steps-hasline' : '',
            className ?? '',
        ]
            .filter(Boolean)
            .join(' '),
    );

    <>
        <div class={classes} style={style} aria-label={ariaLabel}>
            @for (const step of resolved; key step.stepNumber) {
                <div
                    class={[
                        'lotus-steps-item',
                        `lotus-steps-item-${step.status}`,
                        step.active ? 'lotus-steps-item-active' : '',
                        step.isPreErrorStep ? 'lotus-steps-item-pre-error' : '',
                        step.disabled ? 'lotus-steps-item-disabled' : '',
                    ].filter(Boolean).join(' ')}
                    onClick={() => handleClick(step)}
                >
                    <div class="lotus-steps-item-icon">
                        @if (step.icon) {
                            {step.icon}
                        } @if (!step.icon) {
                            <StatusIcon status={step.status} stepNumber={step.stepNumber} />
                        }
                    </div>
                    <div class="lotus-steps-item-content">
                        @if (step.title) {
                            <div class="lotus-steps-item-title">{step.title}</div>
                        }
                        @if (step.description) {
                            <div class="lotus-steps-item-description">{step.description}</div>
                        }
                    </div>
                </div>
            }
        </div>

        <style>
            .lotus-steps {
                display: flex;
                width: 100%;
            }

            .lotus-steps-horizontal {
                flex-direction: row;
            }

            .lotus-steps-vertical {
                flex-direction: column;
            }

            .lotus-steps-item {
                position: relative;
                display: flex;
                align-items: flex-start;
                gap: var(--lotus-spacing-tight);
                flex: 1;
                cursor: default;
            }

            .lotus-steps-item-disabled {
                opacity: 0.5;
            }

            .lotus-steps-horizontal .lotus-steps-item:not(:last-child)::after {
                content: '';
                position: absolute;
                top: 12px;
                left: calc(24px + var(--lotus-spacing-tight));
                right: calc(-1 * (24px + var(--lotus-spacing-tight)) + 24px);
                height: 1px;
                background: var(--lotus-color-border);
            }

            .lotus-steps-hasline.lotus-steps-horizontal .lotus-steps-item-finish:not(:last-child)::after {
                background: var(--lotus-color-primary);
            }

            .lotus-steps-hasline.lotus-steps-horizontal .lotus-steps-item-pre-error:not(:last-child)::after {
                background: var(--lotus-color-danger);
            }

            .lotus-steps-vertical .lotus-steps-item {
                padding-bottom: var(--lotus-spacing-base);
            }

            .lotus-steps-vertical .lotus-steps-item:not(:last-child)::after {
                content: '';
                position: absolute;
                top: 24px;
                left: 12px;
                bottom: 0;
                width: 1px;
                background: var(--lotus-color-border);
            }

            .lotus-steps-hasline.lotus-steps-vertical .lotus-steps-item-finish:not(:last-child)::after {
                background: var(--lotus-color-primary);
            }

            .lotus-steps-item-icon {
                display: flex;
                align-items: center;
                justify-content: center;
                flex-shrink: 0;
                width: 24px;
                height: 24px;
                border-radius: var(--lotus-border-radius-full);
                font-size: var(--lotus-font-label-size);
                color: var(--lotus-color-text-1);
                border: 1px solid var(--lotus-color-border);
                z-index: 1;
                background: var(--lotus-color-bg-1);
            }

            .lotus-steps-item-number {
                line-height: 1;
            }

            .lotus-steps-item-process .lotus-steps-item-icon,
            .lotus-steps-item-active .lotus-steps-item-icon {
                border-color: var(--lotus-color-primary);
                color: var(--lotus-color-primary);
            }

            .lotus-steps-item-finish .lotus-steps-item-icon {
                border-color: var(--lotus-color-primary);
                color: var(--lotus-color-primary);
            }

            .lotus-steps-item-error .lotus-steps-item-icon {
                border-color: var(--lotus-color-danger);
                color: var(--lotus-color-danger);
            }

            .lotus-steps-item-warning .lotus-steps-item-icon {
                border-color: var(--lotus-color-warning);
                color: var(--lotus-color-warning);
            }

            .lotus-steps-fill .lotus-steps-item-process .lotus-steps-item-icon,
            .lotus-steps-fill .lotus-steps-item-active .lotus-steps-item-icon,
            .lotus-steps-fill .lotus-steps-item-finish .lotus-steps-item-icon {
                background: var(--lotus-color-primary);
                color: #ffffff;
            }

            .lotus-steps-fill .lotus-steps-item-error .lotus-steps-item-icon {
                background: var(--lotus-color-danger);
                color: #ffffff;
            }

            .lotus-steps-fill .lotus-steps-item-warning .lotus-steps-item-icon {
                background: var(--lotus-color-warning);
                color: #ffffff;
            }

            .lotus-steps-item-content {
                display: flex;
                flex-direction: column;
                gap: 2px;
                min-width: 0;
            }

            .lotus-steps-item-title {
                font-size: var(--lotus-font-body-size);
                font-weight: var(--lotus-font-weight-semibold);
                color: var(--lotus-color-text-0);
            }

            .lotus-steps-item-wait .lotus-steps-item-title {
                color: var(--lotus-color-text-1);
                font-weight: var(--lotus-font-weight-regular);
            }

            .lotus-steps-item-description {
                font-size: var(--lotus-font-label-size);
                color: var(--lotus-color-text-1);
            }

            .lotus-steps-small .lotus-steps-item-icon {
                width: 20px;
                height: 20px;
            }

            .lotus-steps-small .lotus-steps-item-title {
                font-size: var(--lotus-font-label-size);
            }
        </style>
    </>
}
