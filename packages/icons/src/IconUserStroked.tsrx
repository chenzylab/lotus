/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconUserStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="M12 14c-3.3 0-6-2.7-6-6s2.7-6 6-6 6 2.7 6 6-2.7 6-6 6m0-10C9.8 4 8 5.8 8 8s1.8 4 4 4 4-1.8 4-4-1.8-4-4-4M21.9 20.6c-.1-.2-2.3-5.6-9.9-5.6s-9.8 5.4-9.9 5.6c-.2.5 0 1.1.6 1.3.5.2 1.1 0 1.3-.5 0-.2 1.8-4.4 8-4.4s8 4.2 8.1 4.4c.2.5.8.8 1.3.5.5-.2.7-.8.5-1.3"/>
    </svg>;
}
