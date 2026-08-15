/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconChat(props: { class?: string; style?: Record<string, any> }) {
    return <svg
        viewBox="0 0 22 20"
        fill="none"
        width="1em"
        height="1em"
        class={props.class}
        style={props.style}
        aria-hidden={true}
        xmlns="http://www.w3.org/2000/svg"
    >
        <path fill="#DFDFE7" d="M18 5a2 2 0 0 0-2-2H2a2 2 0 0 0-2 2v12.586c0 .89 1.077 1.337 1.707.707l1.707-1.707A2 2 0 0 1 4.828 16H16a2 2 0 0 0 2-2z"/><path fill="#49C4FD" d="M4 2a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v12.586c0 .89-1.077 1.337-1.707.707l-1.707-1.707A2 2 0 0 0 17.172 13H6a2 2 0 0 1-2-2z"/><path fill="#F4CE2D" d="M14 2.5h4V4h-4z"/><path fill="#F9FCFF" d="M8 8.5h10V10H8zM8 5.5h10V7H8z"/>
    </svg>;
}
