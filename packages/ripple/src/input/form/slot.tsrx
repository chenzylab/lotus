import { track } from 'ripple';
import { FormContext, type LabelPosition } from './form-context.js';

/**
 * Form.Slot：不绑定字段名的纯布局占位（对齐 Semi Form.Slot），复用与
 * Field 相同的 label/error 展示结构，但不接入 formState（不参与
 * values/校验/reset）——用于把自定义内容（说明文字、按钮组等）对齐进
 * 表单的 label/控件两栏栅格里。
 */
export interface SlotProps {
    label?: any;
    noLabel?: boolean;
    labelPosition?: LabelPosition;
    labelWidth?: string | number;
    error?: any;
    children?: any;
    class?: string;
    style?: Record<string, any>;
}

export function Slot(&{
    label,
    noLabel = false,
    labelPosition,
    labelWidth,
    error,
    children,
    class: className,
    style,
}: SlotProps) @{
    const contextTracked = FormContext.get();

    let &[resolvedLabelPosition] = track(() => labelPosition ?? contextTracked?.value.labelPosition ?? 'top');
    let &[resolvedLabelWidth] = track(() => labelWidth ?? contextTracked?.value.labelWidth);

    let &[classes] = track(() =>
        ['lotus-form-field', 'lotus-form-slot', `lotus-form-field-label-${resolvedLabelPosition}`, className ?? ''].filter(Boolean).join(' '),
    );

    let &[labelStyle] = track(() => (resolvedLabelWidth !== undefined ? { width: typeof resolvedLabelWidth === 'number' ? `${resolvedLabelWidth}px` : resolvedLabelWidth } : undefined));

    <div class={classes} style={style}>
        @if (!noLabel && label != null) {
            <div class="lotus-form-field-label" style={labelStyle}>{label}</div>
        }
        <div class="lotus-form-field-control">
            {children}
            @if (error) {
                <div class="lotus-form-field-error" role="alert">{error}</div>
            }
        </div>
    </div>
}
