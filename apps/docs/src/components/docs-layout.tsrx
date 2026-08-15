import { navGroups } from '../lib/nav';
import { GlobalTokens } from './global-tokens.tsrx';

export interface TocItem {
    href: string;
    text: string;
    level: number;
}

export interface DocsLayoutProps {
    category?: string;
    title?: string;
    brief?: string;
    toc?: TocItem[];
    currentPath?: string;
    children?: any;
}

/**
 * 文档站整体三段式布局：顶部固定导航栏 + 左侧分类导航（多组，非折叠，Phase 1 组件量少时
 * 折叠交互价值不高，留待组件增多后再评估是否需要） + 正文（面包屑/标题/简介+children）
 * + 右侧固定 TOC。对齐 Semi 官网真实布局（2026-08-12 实测截图：semi.design/zh-CN/basic/button）。
 */
export function DocsLayout({ category, title, brief, toc = [], currentPath, children }: DocsLayoutProps) @{
    <>
        <GlobalTokens />

        <header class="lotus-docs-header">
            <a class="lotus-docs-logo" href="/">lotus</a>
            <nav class="lotus-docs-header-nav">
                <a href="/">组件</a>
                <a href="/theme">主题</a>
            </nav>
        </header>

        <div class="lotus-docs-body">
            <aside class="lotus-docs-sidebar">
                @for (const group of navGroups; key group.title) {
                    <div class="lotus-docs-nav-group">
                        <p class="lotus-docs-nav-group-title">{group.title}</p>
                        <ul>
                            @for (const item of group.items; key item.href) {
                                <li>
                                    <a
                                        href={item.href}
                                        class={item.href === currentPath ? 'lotus-docs-nav-active' : ''}
                                    >
                                        {item.text}
                                    </a>
                                </li>
                            }
                        </ul>
                    </div>
                }
            </aside>

            <main class="lotus-docs-content">
                @if (category || title) {
                    <div class="lotus-docs-page-header">
                        @if (category) {
                            <p class="lotus-docs-breadcrumb">{category}</p>
                        }
                        @if (title) {
                            <h1 class="lotus-docs-title">{title}</h1>
                        }
                        @if (brief) {
                            <p class="lotus-docs-brief">{brief}</p>
                        }
                    </div>
                }

                {children}
            </main>

            @if (toc.length > 0) {
                <nav class="lotus-docs-toc">
                    <ul>
                        @for (const item of toc; key item.href) {
                            <li class={`lotus-docs-toc-item lotus-docs-toc-level-${item.level}`}>
                                <a href={item.href}>{item.text}</a>
                            </li>
                        }
                    </ul>
                </nav>
            }
        </div>

        <style>
            :global(body) {
                margin: 0;
                font-family: var(--lotus-font-family);
                color: var(--lotus-color-text-0);
                background: var(--lotus-color-bg-0);
            }

            .lotus-docs-header {
                display: flex;
                align-items: center;
                gap: var(--lotus-spacing-loose);
                height: 60px;
                padding: 0 var(--lotus-spacing-loose);
                border-bottom: 1px solid var(--lotus-color-border);
                position: sticky;
                top: 0;
                background: var(--lotus-color-bg-0);
                z-index: 10;
            }

            .lotus-docs-logo {
                font-size: var(--lotus-font-h5-size);
                font-weight: var(--lotus-font-weight-bold);
                color: var(--lotus-color-text-0);
                text-decoration: none;
            }

            .lotus-docs-header-nav {
                display: flex;
                gap: var(--lotus-spacing-base);
            }

            .lotus-docs-header-nav a {
                color: var(--lotus-color-text-1);
                text-decoration: none;
                font-size: var(--lotus-font-body-size);
            }

            .lotus-docs-body {
                display: grid;
                grid-template-columns: 220px 1fr 200px;
                gap: var(--lotus-spacing-loose);
                max-width: 1400px;
                margin: 0 auto;
                padding: var(--lotus-spacing-loose);
                align-items: start;
            }

            .lotus-docs-sidebar {
                position: sticky;
                top: 76px;
                max-height: calc(100vh - 92px);
                overflow-y: auto;
            }

            .lotus-docs-nav-group {
                margin-bottom: var(--lotus-spacing-base);
            }

            .lotus-docs-nav-group-title {
                font-size: var(--lotus-font-label-size);
                font-weight: var(--lotus-font-weight-bold);
                color: var(--lotus-color-text-2);
                margin: 0 0 var(--lotus-spacing-xs, 4px) 0;
                text-transform: uppercase;
            }

            .lotus-docs-nav-group ul {
                list-style: none;
                padding: 0;
                margin: 0;
            }

            .lotus-docs-nav-group a {
                display: block;
                padding: var(--lotus-spacing-xs, 4px) var(--lotus-spacing-tight);
                border-radius: var(--lotus-border-radius-small);
                color: var(--lotus-color-text-1);
                text-decoration: none;
                font-size: var(--lotus-font-body-size);
            }

            .lotus-docs-nav-group a:hover {
                background: var(--lotus-color-fill-0);
            }

            .lotus-docs-nav-active {
                background: var(--lotus-color-fill-0);
                color: var(--lotus-color-primary) !important;
                font-weight: var(--lotus-font-weight-bold);
            }

            .lotus-docs-content {
                min-width: 0;
            }

            .lotus-docs-page-header {
                margin-bottom: var(--lotus-spacing-loose);
            }

            .lotus-docs-breadcrumb {
                font-size: var(--lotus-font-body-size);
                color: var(--lotus-color-text-2);
                margin: 0 0 var(--lotus-spacing-xs, 4px) 0;
            }

            .lotus-docs-title {
                font-size: var(--lotus-font-h1-size);
                font-weight: var(--lotus-font-weight-bold);
                margin: 0 0 var(--lotus-spacing-tight) 0;
            }

            .lotus-docs-brief {
                font-size: var(--lotus-font-h6-size);
                color: var(--lotus-color-text-1);
                margin: 0;
            }

            .lotus-docs-content :global(.doc-h2) {
                font-size: var(--lotus-font-h2-size);
                font-weight: var(--lotus-font-weight-bold);
                margin-top: var(--lotus-spacing-loose);
                padding-bottom: var(--lotus-spacing-tight);
                border-bottom: 1px solid var(--lotus-color-border);
            }

            .lotus-docs-content :global(.doc-h3) {
                font-size: var(--lotus-font-h3-size);
                font-weight: var(--lotus-font-weight-bold);
                margin-top: var(--lotus-spacing-base);
            }

            .lotus-docs-content :global([class*='language-']) {
                border-radius: var(--lotus-border-radius-medium);
                overflow: hidden;
                margin: var(--lotus-spacing-tight) 0;
                position: relative;
            }

            .lotus-docs-content :global([class*='language-'] .lang) {
                position: absolute;
                top: var(--lotus-spacing-xs, 4px);
                right: var(--lotus-spacing-tight);
                font-size: var(--lotus-font-label-size);
                color: var(--lotus-color-text-2);
                text-transform: uppercase;
            }

            .lotus-docs-content :global(table) {
                width: 100%;
                border-collapse: collapse;
                margin: var(--lotus-spacing-tight) 0;
            }

            .lotus-docs-content :global(th),
            .lotus-docs-content :global(td) {
                border: 1px solid var(--lotus-color-border);
                padding: var(--lotus-spacing-tight) var(--lotus-spacing-base-tight);
                text-align: left;
                font-size: var(--lotus-font-body-size);
            }

            .lotus-docs-content :global(th) {
                background: var(--lotus-color-bg-1);
            }

            .lotus-docs-content :global(.custom-block) {
                border-radius: var(--lotus-border-radius-medium);
                padding: var(--lotus-spacing-base-tight) var(--lotus-spacing-base);
                margin: var(--lotus-spacing-tight) 0;
            }

            .lotus-docs-content :global(.custom-block.info) {
                background: var(--lotus-color-fill-0);
                border-left: 3px solid var(--lotus-color-primary);
            }

            .lotus-docs-content :global(.custom-block-title) {
                font-weight: var(--lotus-font-weight-bold);
                margin-bottom: var(--lotus-spacing-xs, 4px);
            }

            .lotus-docs-toc {
                position: sticky;
                top: 76px;
                font-size: var(--lotus-font-label-size);
            }

            .lotus-docs-toc ul {
                list-style: none;
                padding: 0;
                margin: 0;
                border-left: 1px solid var(--lotus-color-border);
            }

            .lotus-docs-toc-item a {
                display: block;
                padding: var(--lotus-spacing-xs, 4px) 0 var(--lotus-spacing-xs, 4px) var(--lotus-spacing-tight);
                margin-left: -1px;
                border-left: 1px solid transparent;
                color: var(--lotus-color-text-2);
                text-decoration: none;
            }

            .lotus-docs-toc-item a:hover {
                color: var(--lotus-color-text-0);
            }

            .lotus-docs-toc-level-3 {
                padding-left: var(--lotus-spacing-tight);
            }
        </style>
    </>
}
