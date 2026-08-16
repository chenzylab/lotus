import { Avatar, type AvatarProps, type AvatarShape, type AvatarSize } from './index.tsrx';

export type AvatarGroupOverlapFrom = 'start' | 'end';

export interface AvatarGroupItem extends AvatarProps {
    key?: string | number;
}

export interface AvatarGroupProps {
    /** 声明式头像列表。Ripple 没有 children 反射/克隆能力，做不到 Semi 那种
     * "遍历 children 并批量 cloneElement 注入 size/shape" 的实现，因此 lotus 版本
     * 用数据数组承载每个头像的配置，AvatarGroup 内部统一渲染并注入 size/shape，
     * 这是在 Ripple 约束下的诚实设计取舍（同 ButtonGroup 的处理方式）。 */
    items: AvatarGroupItem[];
    shape?: AvatarShape;
    size?: AvatarSize | string;
    maxCount?: number;
    overlapFrom?: AvatarGroupOverlapFrom;
    renderMore?: (restCount: number, restItems: AvatarGroupItem[]) => any;
    class?: string;
    style?: Record<string, any>;
}

export function AvatarGroup(&{
    items,
    shape = 'circle',
    size = 'medium',
    maxCount,
    overlapFrom = 'start',
    renderMore,
    class: className,
    style,
}: AvatarGroupProps) @{
    const hasMax = typeof maxCount === 'number' && maxCount < items.length;
    const visibleItems = hasMax ? items.slice(0, maxCount) : items;
    const restItems = hasMax ? items.slice(maxCount) : [];
    const restCount = restItems.length;

    const classes = ['lotus-avatar-group', className ?? ''].filter(Boolean).join(' ');

    // z-index 用内联 style 按索引计算（不用 CSS class 递增）：tsrx <style> 块是纯 CSS，
    // 不经过 Sass 预处理，无法用 Sass 的 @for 循环生成 21 档 z-index class。
    function zIndexFor(index: number): number {
        return overlapFrom === 'start' ? 100 - index : 80 + index;
    }

    <>
        <div class={classes} style={style} role="list">
            @for (const item of visibleItems; index i) {
                <span style={{ position: 'relative', zIndex: zIndexFor(i) }}>
                    <Avatar {...item} shape={shape} size={size} />
                </span>
            }
            @if (restCount > 0) {
                <span style={{ position: 'relative', zIndex: zIndexFor(visibleItems.length) }}>
                    @if (renderMore) {
                        <>{renderMore(restCount, restItems)}</>
                    } @else {
                        <Avatar shape={shape} size={size} class="lotus-avatar-group-more">{`+${restCount}`}</Avatar>
                    }
                </span>
            }
        </div>

        <style>
            .lotus-avatar-group {
                display: inline-flex;
                align-items: center;
            }

            .lotus-avatar-group :global(.lotus-avatar),
            .lotus-avatar-group :global(.lotus-avatar-wrapper) {
                border: 2px solid var(--lotus-color-bg-1);
                box-sizing: content-box;
            }

            .lotus-avatar-group > span:not(:first-child) {
                margin-left: -12px;
            }

            .lotus-avatar-group :global(.lotus-avatar-group-more) {
                background: var(--lotus-color-fill-2);
            }
        </style>
    </>
}
