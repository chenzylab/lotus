import { Fragment } from 'ripple';

export interface DocDemoCardProps {
    children?: any;
    highlightedSource: string;
}

/**
 * Demo 卡片：渲染结果在上（浅灰底卡片），源码高亮在下——对齐 Semi 官网真实布局
 * （2026-08-12 实测截图：`semi.design/zh-CN/basic/button` 按钮类型 demo 区域）。
 */
export function DocDemoCard({ children, highlightedSource }: DocDemoCardProps) @{
    <>
        <div class="lotus-demo-card">
            <div class="lotus-demo-preview">
                {children}
            </div>
            <div class="lotus-demo-source">
                <Fragment innerHTML={highlightedSource} />
            </div>
        </div>

        <style>
            .lotus-demo-card {
                border: 1px solid var(--lotus-color-border);
                border-radius: var(--lotus-border-radius-medium);
                overflow: hidden;
                margin: var(--lotus-spacing-base) 0;
            }

            .lotus-demo-preview {
                padding: var(--lotus-spacing-loose);
                background: var(--lotus-color-bg-1);
            }

            .lotus-demo-source {
                border-top: 1px solid var(--lotus-color-border);
            }

            .lotus-demo-source :global(pre) {
                margin: 0;
                padding: var(--lotus-spacing-base-tight) var(--lotus-spacing-base);
                overflow-x: auto;
                font-size: var(--lotus-font-body-size);
            }
        </style>
    </>
}
