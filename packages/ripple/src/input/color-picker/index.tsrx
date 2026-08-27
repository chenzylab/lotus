import { track, untrack, effect } from 'ripple';
import {
    ColorPickerFoundation,
    DEFAULT_COLOR_VALUE,
    fromHex,
    rgbaToHex,
    type ColorPickerState,
    type ColorPickerFoundationOptions,
    type ColorFormat,
    type ColorValue,
    type HsvaColor,
} from '@lotus/foundation/input/color-picker';
import { Popover } from '../../show/popover/index.tsrx';
import { IconButton } from '../../basic/icon-button/index.tsrx';
import { IconEyedropper, IconChevronUpDown } from '@lotus/icons';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

export type { ColorFormat, ColorValue, HsvaColor };

interface ColorPickerPanelProps {
    state: ColorPickerState;
    width: number;
    height: number;
    alpha: boolean;
    eyeDropper: boolean;
    eyeDropperSupported: boolean;
    svHandlePos: { x: number; y: number };
    huePos: number;
    alphaPos: number;
    hueBackgroundColor: string;
    onSvNode: (node: HTMLElement) => void;
    onHueNode: (node: HTMLElement) => void;
    onAlphaNode: (node: HTMLElement) => void;
    onPanelNode: (node: HTMLElement) => void;
    onSvDown: (event: MouseEvent) => void;
    onHueDown: (event: MouseEvent) => void;
    onAlphaDown: (event: MouseEvent) => void;
    onSvKeyDown: (event: KeyboardEvent) => void;
    onHueKeyDown: (event: KeyboardEvent) => void;
    onAlphaKeyDown: (event: KeyboardEvent) => void;
    onEyeDropper: () => void;
    onHexInput: (event: Event) => void;
    onRgbaChannelInput: (channel: 'r' | 'g' | 'b' | 'a', event: Event) => void;
    onHsvaChannelInput: (channel: 'h' | 's' | 'v' | 'a', event: Event) => void;
    onFormatToggle: () => void;
}

function ColorPickerPanel(&{
    state,
    width,
    height,
    alpha,
    eyeDropper,
    eyeDropperSupported,
    svHandlePos,
    huePos,
    alphaPos,
    hueBackgroundColor,
    onSvNode,
    onHueNode,
    onAlphaNode,
    onPanelNode,
    onSvDown,
    onHueDown,
    onAlphaDown,
    onSvKeyDown,
    onHueKeyDown,
    onAlphaKeyDown,
    onEyeDropper,
    onHexInput,
    onRgbaChannelInput,
    onHsvaChannelInput,
    onFormatToggle,
}: ColorPickerPanelProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    <>
    <div class="lotus-color-picker-panel" style={{ width: `${width}px` }} ref={(node: HTMLElement) => onPanelNode(node)}>
        <div
            class="lotus-color-picker-sv"
            style={{ width: `${width}px`, height: `${height}px`, background: hueBackgroundColor }}
            ref={(node: HTMLElement) => onSvNode(node)}
            onMouseDown={onSvDown}
        >
            <div class="lotus-color-picker-sv-white" />
            <div class="lotus-color-picker-sv-black" />
            <div
                class="lotus-color-picker-sv-handle"
                style={{ left: `${svHandlePos.x}px`, top: `${svHandlePos.y}px` }}
                role="slider"
                tabIndex={0}
                aria-label={locale.ColorPicker.saturationValue}
                aria-valuenow={state.value.hsva.v}
                onKeyDown={onSvKeyDown}
            />
        </div>

        <div class="lotus-color-picker-bars">
            <div class="lotus-color-picker-bars-main">
                <div
                    class="lotus-color-picker-hue"
                    style={{ width: `${width}px` }}
                    ref={(node: HTMLElement) => onHueNode(node)}
                    onMouseDown={onHueDown}
                >
                    <div
                        class="lotus-color-picker-bar-handle"
                        style={{ left: `${huePos}px` }}
                        role="slider"
                        tabIndex={0}
                        aria-label={locale.ColorPicker.hue}
                        aria-valuemin={0}
                        aria-valuemax={360}
                        aria-valuenow={state.value.hsva.h}
                        onKeyDown={onHueKeyDown}
                    />
                </div>
                @if (alpha) {
                    <div
                        class="lotus-color-picker-alpha"
                        style={{ width: `${width}px` }}
                        ref={(node: HTMLElement) => onAlphaNode(node)}
                        onMouseDown={onAlphaDown}
                    >
                        <div class="lotus-color-picker-alpha-gradient" style={{ background: `linear-gradient(to right, transparent, ${rgbaToHex({ ...state.value.rgba, a: 1 })})` }} />
                        <div
                            class="lotus-color-picker-bar-handle"
                            style={{ left: `${alphaPos}px` }}
                            role="slider"
                            tabIndex={0}
                            aria-label={locale.ColorPicker.alpha}
                            aria-valuemin={0}
                            aria-valuemax={1}
                            aria-valuenow={state.value.hsva.a}
                            onKeyDown={onAlphaKeyDown}
                        />
                    </div>
                }
            </div>
            @if (eyeDropper && eyeDropperSupported) {
                <IconButton
                    icon={<IconEyedropper />}
                    theme="borderless"
                    type="tertiary"
                    aria-label={locale.ColorPicker.picker}
                    onClick={onEyeDropper}
                    class="lotus-color-picker-eyedropper"
                />
            }
        </div>

        <div class="lotus-color-picker-data">
            <div
                class="lotus-color-picker-swatch"
                style={{ background: `rgba(${state.value.rgba.r}, ${state.value.rgba.g}, ${state.value.rgba.b}, ${state.value.rgba.a})` }}
            />
            @if (state.format === 'hex') {
                <input
                    class="lotus-color-picker-input lotus-color-picker-input-hex"
                    value={state.value.hex}
                    aria-label={locale.ColorPicker.hex}
                    onInput={onHexInput}
                />
            } @else if (state.format === 'rgba') {
                <div class="lotus-color-picker-channels">
                    <input class="lotus-color-picker-input" value={state.value.rgba.r} aria-label={locale.ColorPicker.red} onInput={(e: Event) => onRgbaChannelInput('r', e)} />
                    <input class="lotus-color-picker-input" value={state.value.rgba.g} aria-label={locale.ColorPicker.green} onInput={(e: Event) => onRgbaChannelInput('g', e)} />
                    <input class="lotus-color-picker-input" value={state.value.rgba.b} aria-label={locale.ColorPicker.blue} onInput={(e: Event) => onRgbaChannelInput('b', e)} />
                    @if (alpha) {
                        <input class="lotus-color-picker-input" value={state.value.rgba.a} aria-label={locale.ColorPicker.alpha} onInput={(e: Event) => onRgbaChannelInput('a', e)} />
                    }
                </div>
            } @else {
                <div class="lotus-color-picker-channels">
                    <input class="lotus-color-picker-input" value={state.value.hsva.h} aria-label={locale.ColorPicker.hue} onInput={(e: Event) => onHsvaChannelInput('h', e)} />
                    <input class="lotus-color-picker-input" value={state.value.hsva.s} aria-label={locale.ColorPicker.saturation} onInput={(e: Event) => onHsvaChannelInput('s', e)} />
                    <input class="lotus-color-picker-input" value={state.value.hsva.v} aria-label={locale.ColorPicker.value} onInput={(e: Event) => onHsvaChannelInput('v', e)} />
                    @if (alpha) {
                        <input class="lotus-color-picker-input" value={state.value.hsva.a} aria-label={locale.ColorPicker.alpha} onInput={(e: Event) => onHsvaChannelInput('a', e)} />
                    }
                </div>
            }
            <IconButton
                icon={<IconChevronUpDown />}
                theme="borderless"
                type="tertiary"
                aria-label={locale.ColorPicker.toggleFormat}
                onClick={onFormatToggle}
            />
        </div>
    </div>

    <style>
        .lotus-color-picker-panel {
            display: flex;
            flex-direction: column;
            gap: 12px;
            padding: 12px;
            box-sizing: border-box;
        }

        .lotus-color-picker-sv {
            position: relative;
            border-radius: var(--lotus-border-radius-small, 4px);
            cursor: crosshair;
            touch-action: none;
        }

        .lotus-color-picker-sv-white {
            position: absolute;
            inset: 0;
            background: linear-gradient(to right, #fff, rgba(255, 255, 255, 0));
            border-radius: inherit;
        }

        .lotus-color-picker-sv-black {
            position: absolute;
            inset: 0;
            background: linear-gradient(to top, #000, rgba(0, 0, 0, 0));
            border-radius: inherit;
        }

        .lotus-color-picker-sv-handle {
            position: absolute;
            width: 12px;
            height: 12px;
            margin-left: -6px;
            margin-top: -6px;
            border-radius: 50%;
            border: 2px solid #fff;
            box-shadow: 0 0 2px rgba(0, 0, 0, 0.4);
            box-sizing: border-box;
            cursor: pointer;
        }

        .lotus-color-picker-sv-handle:focus-visible {
            outline: 2px solid var(--lotus-color-primary);
            outline-offset: 1px;
        }

        .lotus-color-picker-bars {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .lotus-color-picker-bars-main {
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 8px;
            min-width: 0;
        }

        .lotus-color-picker-hue,
        .lotus-color-picker-alpha {
            position: relative;
            height: 12px;
            border-radius: 6px;
            cursor: pointer;
            touch-action: none;
        }

        .lotus-color-picker-hue {
            background: linear-gradient(to right, red, yellow, lime, cyan, blue, magenta, red);
        }

        .lotus-color-picker-alpha {
            background-image:
                linear-gradient(45deg, #ccc 25%, transparent 25%),
                linear-gradient(-45deg, #ccc 25%, transparent 25%),
                linear-gradient(45deg, transparent 75%, #ccc 75%),
                linear-gradient(-45deg, transparent 75%, #ccc 75%);
            background-size: 8px 8px;
            background-position: 0 0, 0 4px, 4px -4px, -4px 0;
        }

        .lotus-color-picker-alpha-gradient {
            position: absolute;
            inset: 0;
            border-radius: inherit;
        }

        .lotus-color-picker-bar-handle {
            position: absolute;
            top: 50%;
            width: 14px;
            height: 14px;
            margin-left: -7px;
            margin-top: -7px;
            border-radius: 50%;
            background: #fff;
            border: 1px solid rgba(0, 0, 0, 0.2);
            box-shadow: 0 0 2px rgba(0, 0, 0, 0.4);
            box-sizing: border-box;
            cursor: pointer;
        }

        .lotus-color-picker-bar-handle:focus-visible {
            outline: 2px solid var(--lotus-color-primary);
            outline-offset: 1px;
        }

        .lotus-color-picker-eyedropper {
            flex-shrink: 0;
        }

        .lotus-color-picker-data {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .lotus-color-picker-swatch {
            width: 24px;
            height: 24px;
            border-radius: var(--lotus-border-radius-small, 4px);
            border: 1px solid var(--lotus-color-border);
            flex-shrink: 0;
            background-image:
                linear-gradient(45deg, #ccc 25%, transparent 25%),
                linear-gradient(-45deg, #ccc 25%, transparent 25%),
                linear-gradient(45deg, transparent 75%, #ccc 75%),
                linear-gradient(-45deg, transparent 75%, #ccc 75%);
            background-size: 8px 8px;
            background-position: 0 0, 0 4px, 4px -4px, -4px 0;
        }

        .lotus-color-picker-channels {
            flex: 1;
            display: flex;
            gap: 4px;
            min-width: 0;
        }

        .lotus-color-picker-input {
            flex: 1;
            min-width: 0;
            height: 28px;
            padding: 0 6px;
            border-radius: var(--lotus-border-radius-small, 4px);
            border: 1px solid var(--lotus-color-border);
            background: var(--lotus-color-bg-1);
            color: var(--lotus-color-text-0);
            font-size: var(--lotus-font-caption-size);
            box-sizing: border-box;
        }

        .lotus-color-picker-input-hex {
            flex: 1;
        }

        .lotus-color-picker-input:focus-visible {
            outline: 2px solid var(--lotus-color-primary);
            outline-offset: -1px;
        }
    </style>
    </>
}

export interface ColorPickerProps {
    value?: ColorValue;
    defaultValue?: ColorValue;
    onChange?: (value: ColorValue) => void;
    alpha?: boolean;
    width?: number;
    height?: number;
    defaultFormat?: ColorFormat;
    eyeDropper?: boolean;
    usePopover?: boolean;
    className?: string;
    style?: Record<string, any>;
    children?: any;
    'aria-label'?: string;
}

function clamp(v: number, min: number, max: number): number {
    return Math.min(Math.max(v, min), max);
}

interface ColorPickerTriggerProps {
    triggerChildren?: any;
    rgba: { r: number; g: number; b: number; a: number };
    ariaLabel?: string;
    onClick: () => void;
}

/**
 * usePopover 触发器：children 缺省时渲染默认色块。独立成顶层组件是因为
 * 直接把 `@if (triggerChildren) {...} @else {...}` 写在 <Popover> 的
 * children slot 深层嵌套里，会导致两个分支都判定为 false、渲染出两个
 * 占位注释——这是 tsrx 编译器在"自定义组件 children slot 内部再嵌套
 * @if/@else 引用同一个 children 变量"这一组合下的已知边界情况坑
 * （复现后改用独立顶层组件规避，未继续深挖编译器内部原因）。
 */
function ColorPickerTrigger(&{ triggerChildren, rgba, ariaLabel, onClick }: ColorPickerTriggerProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    <>
    <div onClick={onClick} class="lotus-color-picker-trigger">
        {triggerChildren ?? <div
            class="lotus-color-picker-swatch lotus-color-picker-swatch-trigger"
            style={{ background: `rgba(${rgba.r}, ${rgba.g}, ${rgba.b}, ${rgba.a})` }}
            aria-label={ariaLabel ?? locale.ColorPicker.defaultLabel}
        />}
    </div>

    <style>
        .lotus-color-picker-trigger {
            display: inline-flex;
            cursor: pointer;
        }

        .lotus-color-picker-swatch {
            width: 24px;
            height: 24px;
            border-radius: var(--lotus-border-radius-small, 4px);
            border: 1px solid var(--lotus-color-border);
            flex-shrink: 0;
            background-image:
                linear-gradient(45deg, #ccc 25%, transparent 25%),
                linear-gradient(-45deg, #ccc 25%, transparent 25%),
                linear-gradient(45deg, transparent 75%, #ccc 75%),
                linear-gradient(-45deg, transparent 75%, #ccc 75%);
            background-size: 8px 8px;
            background-position: 0 0, 0 4px, 4px -4px, -4px 0;
        }

        .lotus-color-picker-swatch-trigger {
            cursor: pointer;
        }
    </style>
    </>
}

/** 静态方法：任意合法颜色字符串（十六进制）解析为完整 ColorValue，非法输入返回 null。 */
export function colorStringToValue(raw: string): ColorValue | null {
    return fromHex(raw);
}

/**
 * ColorPicker：拾色器。内部统一用三态 ColorValue（hsva/rgba/hex）表示颜色，
 * 任意一路变更都会重算另外两路整体上抛（对齐 Semi semi-foundation/colorPicker
 * 的设计）。面板结构自上而下：饱和度-明度矩形 → 色相条 → 透明度条（仅
 * alpha=true）→ 数据区（色块 + 输入框组 + 格式切换 + 吸管）。三个可拖拽
 * 区域统一走 document 级 mousemove/mouseup 监听（复用 lotus Slider 已验证的
 * 模式，注意用 onMouseDown 不用 onPointerDown——对齐 Slider 踩坑 #81：项目里
 * 没有组件验证过 onPointerDown 在 Playwright 下的行为）。
 *
 * Semi 源码没有 presetColors / disabled / onChangeComplete，也完全没有键盘
 * 交互（无 role=slider、无 tabIndex、无 onKeyDown）——这里不额外发明前两者，
 * 但补上键盘无障碍能力（方向键步进），对齐参考实现 chenzy.design 已验证的
 * 增强方案，满足项目 a11y 审计要求。
 */
export function ColorPicker(&{
    value,
    defaultValue,
    onChange,
    alpha = true,
    width = 280,
    height = 280,
    defaultFormat = 'hex',
    eyeDropper = true,
    usePopover = false,
    className,
    style,
    children: triggerChildren,
    'aria-label': ariaLabel,
}: ColorPickerProps) @{
    const isControlled = value !== undefined;

    let &[state] = track<ColorPickerState>({
        value: isControlled ? value! : (defaultValue ?? DEFAULT_COLOR_VALUE),
        format: defaultFormat,
    });

    const foundationOpts: ColorPickerFoundationOptions = { alpha };

    const foundation = new ColorPickerFoundation(
        {
            getState: () => untrack(() => state),
            setState: (patch: Partial<ColorPickerState>) => { state = { ...untrack(() => state), ...patch }; },
        },
        foundationOpts,
    );

    // alpha 运行时可能变化，Foundation 内部大量方法直接读 this.opts.alpha
    // 决定是否保留透明度通道——不同步会永远沿用挂载时刻的旧配置（对齐
    // Slider RTL opts 固化踩坑 #98 的修复方式：修改共享的 opts 对象引用，
    // 不重新构造 Foundation）。
    effect(() => {
        foundationOpts.alpha = alpha;
    });

    effect(() => {
        if (value === undefined) return;
        untrack(() => { state = { ...state, value: value! }; });
    });

    function emit(next: ColorValue) {
        onChange?.(next);
    }

    // ===================== 饱和度-明度矩形 =====================

    let svNode: HTMLElement | null = null;
    let &[svDragging] = track<boolean>(false);

    function svPointFromEvent(event: MouseEvent): { x: number; y: number } | null {
        if (!svNode) return null;
        const rect = svNode.getBoundingClientRect();
        return { x: clamp(event.clientX - rect.left, 0, rect.width), y: clamp(event.clientY - rect.top, 0, rect.height) };
    }

    function handleSvDown(event: MouseEvent) {
        const point = svPointFromEvent(event);
        if (!point) return;
        untrack(() => { svDragging = true; });
        const next = foundation.handleSaturationValueChange(point.x, point.y, width, height, isControlled);
        emit(next);
    }

    // ===================== 色相条 =====================

    let hueNode: HTMLElement | null = null;
    let &[hueDragging] = track<boolean>(false);

    function huePointFromEvent(event: MouseEvent): number | null {
        if (!hueNode) return null;
        const rect = hueNode.getBoundingClientRect();
        return clamp(event.clientX - rect.left, 0, rect.width);
    }

    function handleHueDown(event: MouseEvent) {
        const x = huePointFromEvent(event);
        if (x === null) return;
        untrack(() => { hueDragging = true; });
        const next = foundation.handleHueChange(x, width, isControlled);
        emit(next);
    }

    // ===================== 透明度条 =====================

    let alphaNode: HTMLElement | null = null;
    let &[alphaDragging] = track<boolean>(false);

    function alphaPointFromEvent(event: MouseEvent): number | null {
        if (!alphaNode) return null;
        const rect = alphaNode.getBoundingClientRect();
        return clamp(event.clientX - rect.left, 0, rect.width);
    }

    function handleAlphaDown(event: MouseEvent) {
        if (!alpha) return;
        const x = alphaPointFromEvent(event);
        if (x === null) return;
        untrack(() => { alphaDragging = true; });
        const next = foundation.handleAlphaChange(x, width, isControlled);
        emit(next);
    }

    effect(() => {
        const handleMove = (event: MouseEvent) => {
            if (untrack(() => svDragging)) {
                const point = svPointFromEvent(event);
                if (point) emit(foundation.handleSaturationValueChange(point.x, point.y, width, height, isControlled));
            } else if (untrack(() => hueDragging)) {
                const x = huePointFromEvent(event);
                if (x !== null) emit(foundation.handleHueChange(x, width, isControlled));
            } else if (untrack(() => alphaDragging)) {
                const x = alphaPointFromEvent(event);
                if (x !== null) emit(foundation.handleAlphaChange(x, width, isControlled));
            }
        };
        const handleUp = () => {
            untrack(() => { svDragging = false; hueDragging = false; alphaDragging = false; });
        };
        document.addEventListener('mousemove', handleMove);
        document.addEventListener('mouseup', handleUp);
        return () => {
            document.removeEventListener('mousemove', handleMove);
            document.removeEventListener('mouseup', handleUp);
        };
    });

    // ===================== 键盘操作（Semi 空白，对齐 chenzy.design 增强） =====================

    function handleSvKeyDown(event: KeyboardEvent) {
        const { hsva } = untrack(() => state).value;
        let patch: Partial<HsvaColor> | null = null;
        switch (event.key) {
            case 'ArrowLeft': patch = { s: clamp(hsva.s - 1, 0, 100) }; break;
            case 'ArrowRight': patch = { s: clamp(hsva.s + 1, 0, 100) }; break;
            case 'ArrowUp': patch = { v: clamp(hsva.v + 1, 0, 100) }; break;
            case 'ArrowDown': patch = { v: clamp(hsva.v - 1, 0, 100) }; break;
            default: return;
        }
        event.preventDefault();
        emit(foundation.handleHsvaInput(patch, isControlled));
    }

    function handleHueKeyDown(event: KeyboardEvent) {
        const { hsva } = untrack(() => state).value;
        let h: number | null = null;
        if (event.key === 'ArrowLeft' || event.key === 'ArrowDown') h = clamp(hsva.h - 1, 0, 360);
        else if (event.key === 'ArrowRight' || event.key === 'ArrowUp') h = clamp(hsva.h + 1, 0, 360);
        else return;
        event.preventDefault();
        emit(foundation.handleHsvaInput({ h }, isControlled));
    }

    function handleAlphaKeyDown(event: KeyboardEvent) {
        if (!alpha) return;
        const { hsva } = untrack(() => state).value;
        let a: number | null = null;
        if (event.key === 'ArrowLeft' || event.key === 'ArrowDown') a = clamp(Number((hsva.a - 0.01).toFixed(2)), 0, 1);
        else if (event.key === 'ArrowRight' || event.key === 'ArrowUp') a = clamp(Number((hsva.a + 0.01).toFixed(2)), 0, 1);
        else return;
        event.preventDefault();
        emit(foundation.handleHsvaInput({ a }, isControlled));
    }

    // ===================== 数据区（DataPart） =====================

    function handleFormatToggle() {
        const order: ColorFormat[] = ['hex', 'rgba', 'hsva'];
        const idx = order.indexOf(untrack(() => state).format);
        foundation.setFormat(order[(idx + 1) % order.length]!);
    }

    function handleHexInput(event: Event) {
        const raw = (event.target as HTMLInputElement).value;
        const next = foundation.handleHexInput(raw, isControlled);
        if (next) emit(next);
    }

    function handleRgbaChannelInput(channel: 'r' | 'g' | 'b' | 'a', event: Event) {
        const raw = (event.target as HTMLInputElement).value;
        const next = foundation.handleRgbaChannelInput(channel, raw, isControlled);
        if (next) emit(next);
    }

    function handleHsvaChannelInput(channel: 'h' | 's' | 'v' | 'a', event: Event) {
        const raw = Number((event.target as HTMLInputElement).value);
        if (!Number.isFinite(raw)) return;
        const next = foundation.handleHsvaInput({ [channel]: raw } as Partial<HsvaColor>, isControlled);
        emit(next);
    }

    async function handleEyeDropper() {
        const w = (window as any).EyeDropper;
        if (!w) return;
        try {
            const result = await new w().open();
            const next = foundation.handleHexInput(result.sRGBHex, isControlled);
            if (next) emit(next);
        } catch {
            // 用户取消吸色，忽略
        }
    }

    let &[eyeDropperSupported] = track<boolean>(() => typeof window !== 'undefined' && Boolean((window as any).EyeDropper));

    // ===================== 浮层开关（usePopover） =====================

    let &[popoverVisible] = track<boolean>(false);
    let rootNode: HTMLElement | null = null;
    let panelNode: HTMLElement | null = null;

    function togglePopover() {
        untrack(() => { popoverVisible = !popoverVisible; });
    }

    effect(() => {
        if (!usePopover) return;
        const handleDocumentMouseDown = (event: MouseEvent) => {
            if (!untrack(() => popoverVisible)) return;
            if (!(event.target instanceof Node)) return;
            const root = untrack(() => rootNode);
            if (root?.contains(event.target)) return;
            const panel = untrack(() => panelNode);
            if (panel?.contains(event.target)) return;
            untrack(() => { popoverVisible = false; });
        };
        document.addEventListener('mousedown', handleDocumentMouseDown);
        return () => document.removeEventListener('mousedown', handleDocumentMouseDown);
    });

    // ===================== 派生展示值 =====================

    let &[svHandlePos] = track<{ x: number; y: number }>(() => {
        const { s, v } = state.value.hsva;
        return foundation.saturationValueToPos(s, v, width, height);
    });

    let &[huePos] = track<number>(() => foundation.hueToPos(state.value.hsva.h, width));
    let &[alphaPos] = track<number>(() => foundation.alphaToPos(state.value.hsva.a, width));

    let &[hueBackgroundColor] = track<string>(() => `hsl(${state.value.hsva.h}, 100%, 50%)`);

    let &[classes] = track<string>(() =>
        ['lotus-color-picker', className ?? ''].filter(Boolean).join(' '),
    );

    let &[panelProps] = track<ColorPickerPanelProps>(() => ({
        state,
        width,
        height,
        alpha,
        eyeDropper,
        eyeDropperSupported,
        svHandlePos,
        huePos,
        alphaPos,
        hueBackgroundColor,
        onSvNode: (node: HTMLElement) => { svNode = node; },
        onHueNode: (node: HTMLElement) => { hueNode = node; },
        onAlphaNode: (node: HTMLElement) => { alphaNode = node; },
        onPanelNode: (node: HTMLElement) => { panelNode = node; },
        onSvDown: handleSvDown,
        onHueDown: handleHueDown,
        onAlphaDown: handleAlphaDown,
        onSvKeyDown: handleSvKeyDown,
        onHueKeyDown: handleHueKeyDown,
        onAlphaKeyDown: handleAlphaKeyDown,
        onEyeDropper: handleEyeDropper,
        onHexInput: handleHexInput,
        onRgbaChannelInput: handleRgbaChannelInput,
        onHsvaChannelInput: handleHsvaChannelInput,
        onFormatToggle: handleFormatToggle,
    }));

    <>
        <div class={classes} style={style} role="group" aria-label={ariaLabel} ref={(node: HTMLElement) => { rootNode = node; }}>
            @if (usePopover) {
                <Popover
                    trigger="custom"
                    visible={popoverVisible}
                    content={<ColorPickerPanel {...panelProps} />}
                    spacing={4}
                >
                    <ColorPickerTrigger
                        triggerChildren={triggerChildren}
                        rgba={state.value.rgba}
                        ariaLabel={ariaLabel}
                        onClick={togglePopover}
                    />
                </Popover>
            } @else {
                <ColorPickerPanel {...panelProps} />
            }
        </div>

        <style>
            .lotus-color-picker {
                display: inline-block;
            }
        </style>
    </>
}
