/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconCarouselStroked(props: { class?: string; style?: Record<string, any> }) {
    return <svg
        viewBox="0 0 24 24"
        fill="none"
        width="1em"
        height="1em"
        class={props.class}
        style={props.style}
        aria-hidden={true}
        xmlns="http://www.w3.org/2000/svg"
    >
        <path fill="currentColor" fill-rule="evenodd" d="M1 6h2v12H1v2h3a1 1 0 0 0 1-1V5a1 1 0 0 0-1-1H1zm6-1a1 1 0 0 1 1-1h8a1 1 0 0 1 1 1v14a1 1 0 0 1-1 1H8a1 1 0 0 1-1-1zm2 1v12h6V6zm10-1a1 1 0 0 1 1-1h3v2h-2v12h2v2h-3a1 1 0 0 1-1-1z" clip-rule="evenodd"/>
    </svg>;
}
