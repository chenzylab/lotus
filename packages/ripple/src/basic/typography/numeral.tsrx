import { TypographyText, type TypographyTextProps } from './text.tsrx';
import { formatNumeral, type NumeralRule, type NumeralTruncate } from '@lotus/foundation/basic/typography';

export type { NumeralRule, NumeralTruncate };

export interface TypographyNumeralProps extends Omit<TypographyTextProps, 'children'> {
    children?: string;
    rule?: NumeralRule;
    precision?: number;
    truncate?: NumeralTruncate;
    parser?: (value: string) => string;
}

/**
 * Numeral：对齐 Semi `Typography.Numeral`，是 Text 的特化版本——格式化字符串
 * 中的数字片段后交给 Text 渲染（Semi 源码 `numeral.tsx` 本质也是
 * `<Base component={'span'} {...props} />`，只是多了一层 `formatNodeDFS`
 * 遍历 children 虚拟节点树）。lotus 没有虚拟 DOM 树概念，`children` 收窄为
 * 纯字符串（对齐 lotus Text/Paragraph 的 ellipsis/copyable 已有惯例：
 * 数值格式化本就只对文本内容有意义，非字符串 children 场景不存在）。
 */
export function TypographyNumeral(&{
    children,
    rule = 'text',
    precision = 0,
    truncate = 'round',
    parser,
    ...rest
}: TypographyNumeralProps) @{
    // 与 TypographyText 同一个既知踩坑：JSX 标签子节点写法（`<Numeral>0.5</Numeral>`）
    // 会被 tsrx 编译器包装成非字符串节点，只有 `children="..."` 显式 prop 写法才
    // 原样传入字符串。这里做运行时防御而非假设调用方一定写对——非字符串场景直接
    // 透传原始 children 给 Text（复用 Text 已有的"非纯文本时禁用 ellipsis 等
    // 文本专属能力"的既定容错逻辑），不尝试格式化，避免 `.match is not a function`
    // 这种指向不明的运行时错误。
    const formatted = typeof children === 'string' ? formatNumeral(children, rule, precision, truncate, parser) : children;

    <TypographyText {...rest}>{formatted}</TypographyText>
}
