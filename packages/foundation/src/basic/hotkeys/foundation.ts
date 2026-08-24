/**
 * HotKeys 快捷键匹配纯函数。严格对齐 Semi Design semi-foundation/hotKeys
 * （constants.ts + foundation.ts）：Keys 常量值、keyCodeMap、校验规则、
 * 匹配规则逐条镜像，不做本库扩展。无状态（不维护"当前按下按键集合"，
 * Semi 本身是无状态单次 keydown 事件比对），因此不需要 Foundation<S>
 * 状态机基类，与 CodeHighlight/Lottie 同一惯例。
 *
 * `mergeMetaCtrl` 是死 prop：Semi 声明了这个语义（跨平台把 Cmd 和 Ctrl
 * 视为同一修饰键）但 foundation.ts 从未真正读取这个值参与匹配逻辑——
 * Meta/Ctrl 依然被当作两个独立修饰键严格区分。这不是本次实现遗漏，是
 * 对齐 Semi 源码的真实行为（已逐行核实），保留这个 prop 只是为了 API
 * 形状对齐，不产生任何跨平台归一效果。
 */

/** Key 名常量——镜像 Semi Keys enum 的值（小写/原生符号），hotKeys 数组既可用原生字符串也可用这些常量。 */
export const Keys = {
  // 字母
  A: 'a', B: 'b', C: 'c', D: 'd', E: 'e', F: 'f', G: 'g', H: 'h', I: 'i',
  J: 'j', K: 'k', L: 'l', M: 'm', N: 'n', O: 'o', P: 'p', Q: 'q', R: 'r',
  S: 's', T: 't', U: 'u', V: 'v', W: 'w', X: 'x', Y: 'y', Z: 'z',
  // 数字
  Digit0: '0', Digit1: '1', Digit2: '2', Digit3: '3', Digit4: '4',
  Digit5: '5', Digit6: '6', Digit7: '7', Digit8: '8', Digit9: '9',
  // 符号
  Space: ' ', Enter: 'enter', Escape: 'escape', Backspace: 'backspace',
  Tab: 'tab', Minus: '-', Equal: '=', BracketLeft: '[', BracketRight: ']',
  Backslash: '\\', Semicolon: ';', Quote: "'", Backquote: '`', Comma: ',',
  Period: '.', Slash: '/', Exclamation: '!', At: '@', Hash: '#', Dollar: '$',
  Percent: '%', Caret: '^', Ampersand: '&', Asterisk: '*',
  LeftParenthesis: '(', RightParenthesis: ')',
  // 方向
  ArrowUp: 'arrowup', ArrowDown: 'arrowdown', ArrowLeft: 'arrowleft', ArrowRight: 'arrowright',
  // 修饰键
  Shift: 'shift', Control: 'control', Alt: 'alt', Meta: 'meta',
  // 功能/编辑/导航
  CapsLock: 'capslock', F1: 'f1', F2: 'f2', F3: 'f3', F4: 'f4', F5: 'f5', F6: 'f6',
  F7: 'f7', F8: 'f8', F9: 'f9', F10: 'f10', F11: 'f11', F12: 'f12',
  Insert: 'insert', Delete: 'delete', Home: 'home', End: 'end',
  PageUp: 'pageup', PageDown: 'pagedown',
  NumLock: 'numlock', ScrollLock: 'scrolllock', Pause: 'pause',
  // 小键盘
  Numpad0: 'numpad0', Numpad1: 'numpad1', Numpad2: 'numpad2', Numpad3: 'numpad3',
  Numpad4: 'numpad4', Numpad5: 'numpad5', Numpad6: 'numpad6', Numpad7: 'numpad7',
  Numpad8: 'numpad8', Numpad9: 'numpad9', NumpadDecimal: 'numpaddecimal',
  NumpadDivide: 'numpaddivide', NumpadMultiply: 'numpadmultiply',
  NumpadSubtract: 'numpadsubtract', NumpadAdd: 'numpadadd', NumpadEnter: 'numpadenter',
} as const;

const VALID_KEY_VALUES = new Set<string>(Object.values(Keys));
const MODIFIER_KEYS = new Set<string>(['control', 'meta', 'shift', 'alt']);

function isModifierKey(k: string): boolean {
  return MODIFIER_KEYS.has(k.toLowerCase());
}

export type HotKey = string;

/** 镜像 Semi keyCodeMap：把 KeyboardEvent.key（小写归一后）映射到对应的 KeyboardEvent.code。 */
const KEY_CODE_MAP: Record<string, string> = {
  a: 'KeyA', b: 'KeyB', c: 'KeyC', d: 'KeyD', e: 'KeyE',
  f: 'KeyF', g: 'KeyG', h: 'KeyH', i: 'KeyI', j: 'KeyJ',
  k: 'KeyK', l: 'KeyL', m: 'KeyM', n: 'KeyN', o: 'KeyO',
  p: 'KeyP', q: 'KeyQ', r: 'KeyR', s: 'KeyS', t: 'KeyT',
  u: 'KeyU', v: 'KeyV', w: 'KeyW', x: 'KeyX', y: 'KeyY', z: 'KeyZ',
  '0': 'Digit0', '1': 'Digit1', '2': 'Digit2', '3': 'Digit3',
  '4': 'Digit4', '5': 'Digit5', '6': 'Digit6', '7': 'Digit7',
  '8': 'Digit8', '9': 'Digit9',
  ' ': 'Space', enter: 'Enter', escape: 'Escape', backspace: 'Backspace',
  tab: 'Tab', '-': 'Minus', '=': 'Equal', '[': 'BracketLeft',
  ']': 'BracketRight', '\\': 'Backslash', ';': 'Semicolon',
  "'": 'Quote', '`': 'Backquote', ',': 'Comma', '.': 'Period',
  '/': 'Slash', '?': 'Slash', '!': 'Digit1', '@': 'Digit2',
  '#': 'Digit3', $: 'Digit4', '%': 'Digit5', '^': 'Digit6',
  '&': 'Digit7', '*': 'Digit8', '(': 'Digit9', ')': 'Digit0',
  arrowup: 'ArrowUp', arrowdown: 'ArrowDown',
  arrowleft: 'ArrowLeft', arrowright: 'ArrowRight',
  shift: 'ShiftLeft', control: 'ControlLeft', alt: 'AltLeft',
  meta: 'MetaLeft', capslock: 'CapsLock', f1: 'F1',
  f2: 'F2', f3: 'F3', f4: 'F4', f5: 'F5', f6: 'F6',
  f7: 'F7', f8: 'F8', f9: 'F9', f10: 'F10', f11: 'F11',
  f12: 'F12', insert: 'Insert', delete: 'Delete', home: 'Home',
  end: 'End', pageup: 'PageUp', pagedown: 'PageDown',
  numlock: 'NumLock', scrolllock: 'ScrollLock', pause: 'Pause',
  numpad0: 'Numpad0', numpad1: 'Numpad1', numpad2: 'Numpad2',
  numpad3: 'Numpad3', numpad4: 'Numpad4', numpad5: 'Numpad5',
  numpad6: 'Numpad6', numpad7: 'Numpad7', numpad8: 'Numpad8',
  numpad9: 'Numpad9', numpaddecimal: 'NumpadDecimal',
  numpaddivide: 'NumpadDivide', numpadmultiply: 'NumpadMultiply',
  numpadsubtract: 'NumpadSubtract', numpadadd: 'NumpadAdd',
  numpadenter: 'NumpadEnter',
};

export function keyToCode(key: HotKey): string | undefined {
  return KEY_CODE_MAP[key.toLowerCase()];
}

interface ParsedHotKeys {
  modifiers: Set<string>;
  plain: HotKey;
}

function parseHotKeys(keys: readonly HotKey[]): ParsedHotKeys {
  const modifiers = new Set<string>();
  let plain = '';
  for (const k of keys) {
    if (isModifierKey(k)) modifiers.add(k.toLowerCase());
    else if (!plain) plain = k;
  }
  return { modifiers, plain };
}

/**
 * 镜像 Semi foundation isValidHotKeys：每个 key（小写归一后）必须属于 Keys
 * 已知值集合，且恰含 1 个普通键 + 0~多修饰键。不检查重复（对齐 Semi）。
 * 非法（未知键名、0 个普通键、≥2 个普通键）抛错，合法返回 true。
 */
export function isValidHotKeys(keys: readonly HotKey[]): boolean {
  let plainCount = 0;
  for (const k of keys) {
    const lower = String(k).toLowerCase();
    if (!VALID_KEY_VALUES.has(lower)) {
      throw new Error(`[HotKeys] ${k} is not a valid key`);
    }
    if (!isModifierKey(lower)) plainCount += 1;
  }
  if (plainCount !== 1) {
    throw new Error('HotKeys must have one common key and 0/some modifier key');
  }
  return true;
}

export interface MatchHotKeysOptions {
  /** 死 prop：见文件头注释，声明了但不改变匹配逻辑（严格对齐 Semi）。 */
  mergeMetaCtrl?: boolean;
}

/**
 * 判断一次 keydown 是否命中组合 keys：
 * - 修饰键精确匹配（组合声明的每个修饰键必须按下，未声明的必须未按下）；
 * - 普通键优先用 event.code 比较（规避输入法/大小写/Shift 干扰），
 *   code 归一后仍不等时回退比较 event.key（宽松兜底）。
 */
export function matchHotKeys(
  event: Pick<KeyboardEvent, 'code' | 'key' | 'metaKey' | 'ctrlKey' | 'shiftKey' | 'altKey'>,
  keys: readonly HotKey[],
  options: MatchHotKeysOptions = {},
): boolean {
  const { modifiers, plain } = parseHotKeys(keys);
  void options.mergeMetaCtrl;

  const wantShift = modifiers.has('shift');
  const wantAlt = modifiers.has('alt');
  if (event.shiftKey !== wantShift) return false;
  if (event.altKey !== wantAlt) return false;
  const wantMeta = modifiers.has('meta');
  const wantCtrl = modifiers.has('control');
  if (event.metaKey !== wantMeta) return false;
  if (event.ctrlKey !== wantCtrl) return false;

  const wantCode = keyToCode(plain);
  if (event.code && wantCode !== undefined && event.code === wantCode) return true;
  return event.key.toLowerCase() === plain.toLowerCase();
}
