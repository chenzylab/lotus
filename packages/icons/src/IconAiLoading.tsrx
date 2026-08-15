/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconAiLoading(props: { class?: string; style?: Record<string, any> }) {
    return <svg
        viewBox="0 0 16 16"
        fill="none"
        width="1em"
        height="1em"
        class={props.class}
        style={props.style}
        aria-hidden={true}
        xmlns="http://www.w3.org/2000/svg"
    >
        <g clip-path="url(#a)"><path stroke="url(#b)" stroke-linecap="round" stroke-width="1.778" d="M15.111 8A7.111 7.111 0 0 0 1.596 4.904"/></g><defs><linearGradient id="b" x1="16" x2="2.686" y1="8" y2="11.022" gradientUnits="userSpaceOnUse"><stop stop-color="#E945FF"/><stop offset=".3" stop-color="#A647FF"/><stop offset=".6" stop-color="#6B61FF"/><stop offset="1" stop-color="#2E8CFF" stop-opacity="0"/></linearGradient><clipPath id="a"><path fill="#fff" d="M0 0h16v16H0z"/></clipPath></defs>
    </svg>;
}
