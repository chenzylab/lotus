/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconTextStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M4 2a1 1 0 0 0-1 1v3a1 1 0 0 0 2 0V4h6v16H9a1 1 0 1 0 0 2h6a1 1 0 1 0 0-2h-2V4h6v2a1 1 0 1 0 2 0V3a1 1 0 0 0-1-1z" clip-rule="evenodd"/>
    </svg>;
}
