/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconCodeHighlight(props: { class?: string; style?: Record<string, any> }) {
    return <svg
        viewBox="0 0 22 18"
        fill="none"
        width="1em"
        height="1em"
        class={props.class}
        style={props.style}
        aria-hidden={true}
        xmlns="http://www.w3.org/2000/svg"
    >
        <rect width="22" height="10" y=".406" fill="#49C4FD" rx="2"/><path fill="#F9FCFF" d="M0 4.594h11v13H2a2 2 0 0 1-2-2zM11 4.594h11v11a2 2 0 0 1-2 2h-9z"/><path stroke="#F8CE27" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="m7 8-3 3 3 3"/><path stroke="#49C4FD" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="m15 8 3 3-3 3"/><path stroke="#E0E4E7" stroke-linecap="round" stroke-width="1.5" d="m12 8-2 6.5"/>
    </svg>;
}
