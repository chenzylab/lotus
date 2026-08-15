/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconBeaker(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M7 9.632V4a1.5 1.5 0 0 1 0-3h10a1.5 1.5 0 0 1 0 3v5.632l5.067 9.712c.868 1.664-.34 3.656-2.217 3.656H4.15c-1.878 0-3.085-1.992-2.217-3.656zM14 4h-4v6a1.5 1.5 0 0 1-.17.694L8.627 13h6.746l-1.203-2.306A1.5 1.5 0 0 1 14 10z" clip-rule="evenodd"/>
    </svg>;
}
