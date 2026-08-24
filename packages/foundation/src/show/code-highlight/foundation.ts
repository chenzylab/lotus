/**
 * CodeHighlight 的类名解析纯函数，与具体高亮库（prismjs）解耦，供渲染层调用。
 * 对齐 Semi semi-foundation/codeHighlight：<code> 元素只加 `language-<lang>`
 * 与（开启行号时）`line-numbers`，无其它内部状态——CodeHighlightBaseState
 * 在 Semi 源码里也是空接口，因此本组件不需要 Foundation<S> 状态机基类。
 */

const LANGUAGE_CLASS_RE = /(^|\s)language-\S+/;

/**
 * 解析 <code> 元素应有的 class 字符串。若已存在 language-* 类不重复添加
 * （避免多次高亮后类名重叠冲突）；line-numbers 按开关增删。
 */
export function resolveCodeClassName(
  currentClassName: string,
  language: string,
  lineNumber: boolean = true,
): string {
  const classes = (currentClassName ?? '')
    .split(/\s+/)
    .filter((c) => c && c !== 'line-numbers');

  const hasLanguage = LANGUAGE_CLASS_RE.test(currentClassName ?? '');
  if (!hasLanguage && language) {
    classes.push(`language-${language}`);
  }

  if (lineNumber) {
    classes.push('line-numbers');
  }

  return classes.join(' ');
}
