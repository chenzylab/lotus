import { track, untrack, effect } from 'ripple';
import {
    PinCodeFoundation,
    type PinCodeState,
    type PinCodeFormat,
} from '@lotus/foundation/input/pin-code';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

export type PinCodeSize = 'small' | 'default' | 'large';
export type PinCodeValidateStatus = 'default' | 'error' | 'warning';

export interface PinCodeProps {
    value?: string;
    defaultValue?: string;
    count?: number;
    format?: PinCodeFormat;
    size?: PinCodeSize;
    disabled?: boolean;
    autoFocus?: boolean;
    validateStatus?: PinCodeValidateStatus;
    onChange?: (value: string) => void;
    onComplete?: (value: string) => void;
    'aria-label'?: string;
    style?: Record<string, any>;
    class?: string;
}

function inputModeFor(format: PinCodeFormat): 'numeric' | 'text' {
    return format === 'number' ? 'numeric' : 'text';
}

/**
 * PinCode：验证码/密码分格输入框。定位为"可见分格短码"，不做遮罩显示
 * （Semi 源码没有 format='mask' 这个能力，需要遮蔽显示的场景应该用
 * Input type="password"，调研已核实）。format 只支持 'number'/'mixed'/
 * RegExp/function 四种，忠实对齐 Semi 类型签名，不引入测试文件里出现但
 * 源码类型不支持的 'text' 幽灵值。
 *
 * 每格是手写裸 <input>（不复用 Input 组件——lotus Input 没有暴露 DOM
 * ref/裸态模式，调研已核实，对齐 TagInput/TextArea 已验证的裸 input +
 * ref 数组模式）。字符校验走"onInput 后回退"而非 onKeyPress 拦截：非法
 * 字符触发原生 input 事件后，Foundation.writeChar 返回 null，不写入
 * state，随后用 DOM 值同步回 state.valueList[index] 强制拉回，实现
 * "非法字符不留痕"的视觉效果（对齐 Semi 受控组件的隐式回退机制）。
 *
 * 焦点自动跳转/Backspace/Delete/方向键忠实对齐 Semi 行为（含"Backspace
 * 无条件清空当前格并回退"、"onComplete 判定写入索引是否为末格，不是
 * valueList 全部非空"这两条容易被误解为 bug 实则是 Semi 真实语义的细节，
 * Foundation 层已加注释说明）。IME 组合输入处理对齐参考实现 chenzy.design
 * 更严谨的方案（显式 onCompositionStart/onCompositionEnd 追踪组合中索引，
 * 组合结束后重新处理最终字符，而非仅被动检测 isComposing 标志位）。
 *
 * 键盘无障碍（role="group"+位次 aria-label+autocomplete="one-time-code"）
 * 对齐参考实现 chenzy.design 已验证的完整方案——Semi 源码在这一点完全
 * 空白（根容器无 role、单格无 aria-label，调研已核实），这是本次调研中
 * 少见的"Semi 全面空白、chenzy.design 全面补齐"的组件，直接采纳其方案
 * 作为 lotus 基线。
 */
export function PinCode(&{
    value,
    defaultValue,
    count = 6,
    format = 'number',
    size = 'default',
    disabled = false,
    autoFocus = true,
    validateStatus = 'default',
    onChange,
    onComplete,
    'aria-label': ariaLabel,
    style,
    class: className,
}: PinCodeProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    const isControlled = value !== undefined;

    let &[state] = track<PinCodeState>({
        valueList: (() => {
            const chars = (isControlled ? value : defaultValue)?.split('').slice(0, count) ?? [];
            const list = [...chars];
            while (list.length < count) {
                list.push('');
            }
            return list;
        })(),
    });

    const foundation = new PinCodeFoundation(
        {
            getState: () => untrack(() => state),
            setState: (patch: Partial<PinCodeState>) => { state = { ...untrack(() => state), ...patch }; },
        },
        { count, format },
    );

    effect(() => {
        if (value === undefined) return;
        const v = value;
        // 读取 count 建立响应式依赖：count 变化时也要重新归一化 valueList 长度。
        count;
        untrack(() => foundation.syncValueList(v));
    });

    let cellNodes: Array<HTMLInputElement | null> = [];
    let composingIndex: number | null = null;

    function emitChange(valueList: string[]) {
        onChange?.(valueList.join(''));
    }

    function moveFocus(index: number | null) {
        if (index === null) {
            cellNodes[cellNodes.length - 1]?.blur();
            return;
        }
        cellNodes[index]?.focus();
    }

    function handleCellInput(index: number, event: Event) {
        if (disabled) return;
        const input = event.target as HTMLInputElement;
        const raw = input.value;
        if (composingIndex === index) return;
        const char = raw.slice(-1);
        if (char === '') {
            input.value = untrack(() => state).valueList[index] ?? '';
            return;
        }
        const result = foundation.writeChar(index, char, isControlled);
        if (!result) {
            input.value = untrack(() => state).valueList[index] ?? '';
            return;
        }
        emitChange(result.valueList);
        if (result.completed) onComplete?.(result.valueList.join(''));
        moveFocus(result.focusIndex);
    }

    function handleCompositionStart(index: number) {
        composingIndex = index;
    }

    function handleCompositionEnd(index: number, event: CompositionEvent) {
        composingIndex = null;
        const char = event.data.slice(-1);
        const input = cellNodes[index];
        if (!char) {
            if (input) input.value = untrack(() => state).valueList[index] ?? '';
            return;
        }
        const result = foundation.writeChar(index, char, isControlled);
        if (!result) {
            if (input) input.value = untrack(() => state).valueList[index] ?? '';
            return;
        }
        emitChange(result.valueList);
        if (result.completed) onComplete?.(result.valueList.join(''));
        moveFocus(result.focusIndex);
    }

    function handleCellKeyDown(index: number, event: KeyboardEvent) {
        if (disabled) return;
        if (event.key !== 'Backspace' && event.key !== 'Delete' && event.key !== 'ArrowLeft' && event.key !== 'ArrowRight') return;
        event.preventDefault();
        const result = foundation.handleFocusMoveKey(event.key, index, isControlled);
        if (!result) return;
        if (event.key === 'Backspace' || event.key === 'Delete') emitChange(result.valueList);
        moveFocus(result.focusIndex);
    }

    function handleCellPaste(index: number, event: ClipboardEvent) {
        if (disabled) return;
        event.preventDefault();
        const text = event.clipboardData?.getData('text') ?? '';
        if (text === '') return;
        const result = foundation.handlePaste(index, text, isControlled);
        emitChange(result.valueList);
        if (result.completed) onComplete?.(result.valueList.join(''));
        moveFocus(result.focusIndex);
    }

    effect(() => {
        if (!autoFocus || disabled) return;
        untrack(() => cellNodes[0]?.focus());
    });

    let &[classes] = track<string>(() =>
        [
            'lotus-pin-code',
            `lotus-pin-code-${size}`,
            validateStatus !== 'default' ? `lotus-pin-code-${validateStatus}` : '',
            disabled ? 'lotus-pin-code-disabled' : '',
            className ?? '',
        ].filter(Boolean).join(' '),
    );

    <>
        <div class={classes} style={style} role="group" aria-label={ariaLabel}>
            @for (const cell of state.valueList; index ci) {
                <input
                    type="text"
                    inputmode={inputModeFor(format)}
                    autocomplete="one-time-code"
                    class="lotus-pin-code-cell"
                    value={cell}
                    disabled={disabled}
                    maxlength={1}
                    aria-label={locale.PinCode.digitLabel(ci + 1, count)}
                    aria-invalid={validateStatus === 'error'}
                    onInput={(e: Event) => handleCellInput(ci, e)}
                    onKeyDown={(e: KeyboardEvent) => handleCellKeyDown(ci, e)}
                    onPaste={(e: ClipboardEvent) => handleCellPaste(ci, e)}
                    onCompositionStart={() => handleCompositionStart(ci)}
                    onCompositionEnd={(e: CompositionEvent) => handleCompositionEnd(ci, e)}
                    ref={(node: HTMLInputElement) => { cellNodes[ci] = node; }}
                />
            }
        </div>

        <style>
            .lotus-pin-code {
                display: inline-flex;
                gap: 8px;
            }

            .lotus-pin-code-cell {
                width: 40px;
                height: var(--lotus-height-control-default, 32px);
                text-align: center;
                border: 1px solid var(--lotus-color-border);
                border-radius: var(--lotus-border-radius-small, 4px);
                background: var(--lotus-color-bg-1);
                color: var(--lotus-color-text-0);
                font-family: var(--lotus-font-family);
                font-size: var(--lotus-font-body-size);
                outline: none;
                box-sizing: border-box;
            }

            .lotus-pin-code-cell:focus {
                border-color: var(--lotus-color-primary);
                box-shadow: 0 0 0 2px var(--lotus-color-primary-light, rgba(0, 100, 250, 0.2));
            }

            .lotus-pin-code-small .lotus-pin-code-cell {
                width: 32px;
                height: 24px;
            }

            .lotus-pin-code-large .lotus-pin-code-cell {
                width: 48px;
                height: 40px;
                font-size: var(--lotus-font-heading-size, 18px);
            }

            .lotus-pin-code-error .lotus-pin-code-cell {
                border-color: var(--lotus-color-danger, #d94711);
            }

            .lotus-pin-code-warning .lotus-pin-code-cell {
                border-color: var(--lotus-color-warning, #fadb14);
            }

            .lotus-pin-code-disabled .lotus-pin-code-cell {
                cursor: not-allowed;
                opacity: 0.6;
                background: var(--lotus-color-fill-0);
            }
        </style>
    </>
}
