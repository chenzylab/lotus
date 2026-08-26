import { track } from 'ripple';
import { NavContext } from './nav-context.js';

export interface NavHeaderProps {
    children?: any;
    logo?: any;
    text?: any;
    link?: string;
    linkOptions?: Record<string, any>;
    style?: Record<string, any>;
    class?: string;
}

export function NavHeader(&{ children, logo, text, link, linkOptions, style, class: className }: NavHeaderProps) @{
    const contextTracked = NavContext.get();

    let &[isCollapsed] = track(() => contextTracked?.value.isCollapsed ?? false);

    // 必须用显式 track()（而非普通 const）——见 item.tsrx 踩坑记录（踩坑 #19）。
    let &[classes] = track(() =>
        ['lotus-nav-header', isCollapsed ? 'lotus-nav-header-collapsed' : '', className ?? '']
            .filter(Boolean)
            .join(' '),
    );

    <>
        @if (typeof link === 'string') {
            <a class="lotus-nav-header-link" href={link} {...(linkOptions ?? {})}>
                <div class={classes} style={style}>
                    @if (logo != null) {
                        <i class="lotus-nav-header-logo">{logo}</i>
                    }
                    @if (text != null && !isCollapsed) {
                        <span class="lotus-nav-header-text">{text}</span>
                    }
                    {children}
                </div>
            </a>
        } @else {
            <div class={classes} style={style}>
                @if (logo != null) {
                    <i class="lotus-nav-header-logo">{logo}</i>
                }
                @if (text != null && !isCollapsed) {
                    <span class="lotus-nav-header-text">{text}</span>
                }
                {children}
            </div>
        }

        <style>
            .lotus-nav-header {
                display: flex;
                align-items: center;
                height: 60px;
                padding: 0 24px;
                box-sizing: border-box;
                overflow: hidden;
                white-space: nowrap;
            }

            .lotus-nav-header-collapsed {
                padding: 0;
                justify-content: center;
            }

            .lotus-nav-header-logo {
                display: inline-flex;
                align-items: center;
                font-style: normal;
                flex-shrink: 0;
            }

            .lotus-nav-header-text {
                margin-inline-start: 8px;
                font-size: var(--lotus-font-heading-size, 16px);
                font-weight: var(--lotus-font-weight-semibold);
                color: var(--lotus-color-text-0);
                overflow: hidden;
                text-overflow: ellipsis;
            }

            .lotus-nav-header-link {
                display: block;
                text-decoration: none;
                color: inherit;
            }
        </style>
    </>
}
