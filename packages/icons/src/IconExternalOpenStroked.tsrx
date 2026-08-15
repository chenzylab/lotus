/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconExternalOpenStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M21 2a1 1 0 0 1 1 1v6a1 1 0 1 1-2 0V5.414l-9.293 9.293a1 1 0 0 1-1.414-1.414L18.586 4H15a1 1 0 1 1 0-2zM2 5a1 1 0 0 1 1-1h8a1 1 0 1 1 0 2H4v14h14v-7a1 1 0 1 1 2 0v8a1 1 0 0 1-1 1H3a1 1 0 0 1-1-1z" clip-rule="evenodd"/>
    </svg>;
}
