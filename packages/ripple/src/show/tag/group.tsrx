import { track } from 'ripple';
import { Tag, type TagProps, type TagSize, type TagAvatarShape } from './index.tsrx';
import { Popover, type PopoverProps } from '../popover/index.tsrx';

export interface TagGroupProps<T extends TagProps = TagProps> {
    /** 声明式标签配置数组。每项自动补齐 `size`/`avatarShape`（未显式指定时用
     * group 级默认值）与 `tagKey`（未指定时用字符串/数字 children 兜底，
     * 否则用数组下标——比 Semi 的 `Math.random()` 更稳定，避免受控场景下
     * 每次渲染 key 漂移）。 */
    tagList: T[];
    style?: Record<string, any>;
    class?: string;
    /** 展示的标签数量上限，超出的聚合成 "+N" 标签。 */
    maxTagCount?: number;
    /** "+N" 里的 N 值，未显式指定时用 `tagList.length - maxTagCount` 推算。 */
    restCount?: number;
    size?: TagSize;
    avatarShape?: TagAvatarShape;
    /** hover "+N" 标签时是否用 Popover 展示被折叠的完整标签列表。 */
    showPopover?: boolean;
    popoverProps?: Partial<PopoverProps>;
    /** group 级统一关闭回调：每个标签自身的 `onClose`（如果有）先触发，再触发这个。 */
    onTagClose?: (children: any, event: MouseEvent | KeyboardEvent, tagKey: string | number | undefined) => void;
    onPlusNMouseEnter?: () => void;
    'aria-label'?: string;
}

export function TagGroup<T extends TagProps = TagProps>(&{
    tagList,
    style,
    class: className,
    maxTagCount,
    restCount,
    size = 'default',
    avatarShape = 'square',
    showPopover = false,
    popoverProps,
    onTagClose,
    onPlusNMouseEnter,
    'aria-label': ariaLabel,
}: TagGroupProps<T>) @{
    let &[classes] = track<string>(() =>
        [
            'lotus-tag-group',
            maxTagCount !== undefined ? 'lotus-tag-group-max' : '',
            size === 'small' ? 'lotus-tag-group-small' : '',
            size === 'large' ? 'lotus-tag-group-large' : '',
            className ?? '',
        ].filter(Boolean).join(' '),
    );

    let &[resolvedTags] = track<T[]>(() =>
        tagList.map((tag, index) => ({
            ...tag,
            size: tag.size ?? size,
            avatarShape: tag.avatarShape ?? avatarShape,
            tagKey: tag.tagKey ?? (typeof tag.children === 'string' || typeof tag.children === 'number' ? tag.children : index),
        })),
    );

    let &[visibleTags] = track<T[]>(() => (maxTagCount === undefined ? resolvedTags : resolvedTags.slice(0, maxTagCount)));
    let &[restTags] = track<T[]>(() => (maxTagCount === undefined ? [] : resolvedTags.slice(maxTagCount)));
    let &[remainingCount] = track<number>(() => (restCount ?? restTags.length));

    function handleTagClose(tag: T) {
        return (children: any, event: MouseEvent | KeyboardEvent, tagKey: string | number | undefined) => {
            tag.onClose?.(children, event, tagKey);
            onTagClose?.(children, event, tagKey);
        };
    }

    <>
        <div class={classes} style={style} aria-label={ariaLabel}>
            @for (const tag of visibleTags; index i; key tag.tagKey ?? i) {
                <Tag {...tag} onClose={handleTagClose(tag)} />
            }
            @if (remainingCount > 0) {
                <>
                    @if (showPopover) {
                        <Popover
                            showArrow
                            trigger="hover"
                            position="top"
                            autoAdjustOverflow
                            class="lotus-tag-group-rest-popover"
                            {...(popoverProps ?? {})}
                            content={
                                <div class="lotus-tag-group-rest-list">
                                    @for (const tag of restTags; index i; key tag.tagKey ?? i) {
                                        <Tag {...tag} onClose={handleTagClose(tag)} />
                                    }
                                </div>
                            }
                        >
                            <Tag closable={false} size={size} color="grey" style={{ backgroundColor: 'transparent' }} onMouseEnter={onPlusNMouseEnter}>
                                {`+${remainingCount}`}
                            </Tag>
                        </Popover>
                    }
                    @if (!showPopover) {
                        <Tag closable={false} size={size} color="grey" style={{ backgroundColor: 'transparent' }} onMouseEnter={onPlusNMouseEnter}>
                            {`+${remainingCount}`}
                        </Tag>
                    }
                </>
            }
        </div>

        <style>
            .lotus-tag-group {
                display: inline-flex;
                align-items: center;
                flex-wrap: wrap;
                gap: 4px;
            }

            .lotus-tag-group-rest-list {
                display: flex;
                flex-direction: column;
                gap: 4px;
                max-width: 240px;
            }
        </style>
    </>
}
