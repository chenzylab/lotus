import { formatVideoTime } from '@lotus/foundation/show/video-player';
import type { AnnotationGroup, AnnotationItem } from '@lotus/foundation/show/sidebar';
import { Collapse } from '../collapse/index.tsrx';
import { CollapsePanel } from '../collapse/panel.tsrx';
import { IconPlay } from '@lotus/icons';

export type { AnnotationGroup, AnnotationItem };

export interface AnnotationProps {
    info?: AnnotationGroup[];
    activeKey?: string | string[];
    onChange?: (activeKey: string[]) => void;
    onClick?: (event: MouseEvent, item: AnnotationItem) => void;
    renderItem?: (annotation: AnnotationItem) => any;
    class?: string;
    style?: Record<string, any>;
}

function handleItemClick(event: MouseEvent, item: AnnotationItem, onClick?: (event: MouseEvent, item: AnnotationItem) => void) {
    if (item.url) window.open(item.url, '_blank', 'noopener,noreferrer');
    onClick?.(event, item);
}

/**
 * Sidebar.Annotation：引用溯源分组视图，每组一个 Collapse.Panel（与
 * CodeContent 同一容器模式）。video 类型叠加播放图标+`formatVideoTime`
 * 时长角标（跨组件复用 VideoPlayer 已验证的时间格式化纯函数）。
 */
export function Annotation(&{ info, activeKey, onChange, onClick, renderItem, class: className, style }: AnnotationProps) @{
    function handleChange(keys: string[]) {
        onChange?.(keys);
    }

    <>
        <div class={['lotus-sidebar-annotation', className ?? ''].filter(Boolean).join(' ')} style={style}>
            <Collapse activeKey={activeKey} onChange={handleChange}>
                @for (const group of info ?? []; key group.key) {
                    <CollapsePanel itemKey={group.key} header={group.header ?? group.key}>
                        <div class="lotus-sidebar-annotation-list">
                            @for (const item of group.annotations; index i) {
                                @if (renderItem) {
                                    <>{renderItem(item)}</>
                                } @else {
                                    <div
                                        class={['lotus-sidebar-annotation-item', `lotus-sidebar-annotation-item-${item.type}`].filter(Boolean).join(' ')}
                                        role="button"
                                        tabIndex={0}
                                        onClick={(event: MouseEvent) => handleItemClick(event, item, onClick)}
                                    >
                                        @if (item.type === 'video') {
                                            <>
                                                <div class="lotus-sidebar-annotation-thumb">
                                                    @if (item.img) {
                                                        <img src={item.img} alt={item.title ?? ''} />
                                                    }
                                                    <span class="lotus-sidebar-annotation-play"><IconPlay /></span>
                                                    @if (item.duration !== undefined) {
                                                        <span class="lotus-sidebar-annotation-duration">{formatVideoTime(item.duration)}</span>
                                                    }
                                                </div>
                                                <div class="lotus-sidebar-annotation-title">{item.title}</div>
                                            </>
                                        } @else {
                                            <>
                                                <div class="lotus-sidebar-annotation-title">{item.title}</div>
                                                @if (item.detail) {
                                                    <div class="lotus-sidebar-annotation-detail">{item.detail}</div>
                                                }
                                                <div class="lotus-sidebar-annotation-footer">
                                                    @if (item.logo) {
                                                        <img class="lotus-sidebar-annotation-logo" src={item.logo} alt="" />
                                                    }
                                                    @if (item.siteName) {
                                                        <span class="lotus-sidebar-annotation-site">{item.siteName}</span>
                                                    }
                                                    @if (item.order !== undefined) {
                                                        <span class="lotus-sidebar-annotation-order">{item.order}</span>
                                                    }
                                                </div>
                                            </>
                                        }
                                    </div>
                                }
                            }
                        </div>
                    </CollapsePanel>
                }
            </Collapse>
        </div>

        <style>
            .lotus-sidebar-annotation-list {
                display: flex;
                flex-direction: column;
                gap: 8px;
            }

            .lotus-sidebar-annotation-item {
                border: 1px solid var(--lotus-color-border);
                border-radius: var(--lotus-border-radius-small);
                padding: 8px;
                cursor: pointer;
            }

            .lotus-sidebar-annotation-item:hover {
                border-color: var(--lotus-color-primary);
            }

            .lotus-sidebar-annotation-thumb {
                position: relative;
                display: flex;
                align-items: center;
                justify-content: center;
                background: var(--lotus-color-fill-0);
                border-radius: var(--lotus-border-radius-small);
                overflow: hidden;
                aspect-ratio: 16 / 9;
            }

            .lotus-sidebar-annotation-thumb img {
                width: 100%;
                height: 100%;
                object-fit: cover;
            }

            .lotus-sidebar-annotation-play {
                position: absolute;
                inset: 0;
                display: flex;
                align-items: center;
                justify-content: center;
                color: #fff;
                font-size: 24px;
            }

            .lotus-sidebar-annotation-duration {
                position: absolute;
                right: 4px;
                bottom: 4px;
                background: rgba(0, 0, 0, 0.7);
                color: #fff;
                font-size: 11px;
                padding: 0 4px;
                border-radius: 2px;
            }

            .lotus-sidebar-annotation-title {
                margin-top: 6px;
                font-size: 13px;
                color: var(--lotus-color-text-0);
            }

            .lotus-sidebar-annotation-detail {
                margin-top: 2px;
                font-size: 12px;
                color: var(--lotus-color-text-2);
            }

            .lotus-sidebar-annotation-footer {
                display: flex;
                align-items: center;
                gap: 4px;
                margin-top: 6px;
                font-size: 12px;
                color: var(--lotus-color-text-3);
            }

            .lotus-sidebar-annotation-logo {
                width: 14px;
                height: 14px;
                border-radius: 2px;
            }
        </style>
    </>
}
