export interface SplitTagGroupProps {
    children?: any;
    style?: Record<string, any>;
    class?: string;
    'aria-label'?: string;
}

/**
 * 把一组 Tag 兄弟节点渲染成视觉上连成一体的分段标签组：首尾两端保留圆角，
 * 中间零圆角、彼此贴合。Semi 用 `React.Children.map` + `cloneElement` 遍历
 * children 手动注入 `semi-tag-first`/`semi-tag-last` class；lotus 用纯 CSS
 * `:first-child`/`:last-child` 选择器达到完全相同的视觉效果，不需要任何
 * JS 遍历/克隆——圆角样式本身就是靠 class 选择器实现的（不依赖内联
 * style），核对 Semi 源码后确认这是可以更简单实现的场景，不是"Ripple
 * 缺少 children 反射能力"这类需要架构取舍的限制。
 */
export function SplitTagGroup(&{ children, style, class: className, 'aria-label': ariaLabel }: SplitTagGroupProps) @{
    <>
        <div class={['lotus-tag-split', className ?? ''].filter(Boolean).join(' ')} style={style} role="group" aria-label={ariaLabel}>
            {children}
        </div>

        <style>
            .lotus-tag-split {
                display: inline-flex;
                align-items: center;
            }

            .lotus-tag-split > :global(.lotus-tag) {
                border-radius: 0;
                margin-inline-end: 1px;
            }

            .lotus-tag-split > :global(.lotus-tag):first-child {
                border-start-start-radius: var(--lotus-border-radius-small);
                border-end-start-radius: var(--lotus-border-radius-small);
            }

            .lotus-tag-split > :global(.lotus-tag):last-child {
                border-start-end-radius: var(--lotus-border-radius-small);
                border-end-end-radius: var(--lotus-border-radius-small);
                margin-inline-end: 0;
            }

            .lotus-tag-split > :global(.lotus-tag-circle):first-child {
                border-start-start-radius: var(--lotus-border-radius-full);
                border-end-start-radius: var(--lotus-border-radius-full);
            }

            .lotus-tag-split > :global(.lotus-tag-circle):last-child {
                border-start-end-radius: var(--lotus-border-radius-full);
                border-end-end-radius: var(--lotus-border-radius-full);
            }
        </style>
    </>
}
