/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconMaximize(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M14 3.5A1.5 1.5 0 0 1 15.5 2h3A3.5 3.5 0 0 1 22 5.5v3a1.5 1.5 0 0 1-3 0v-3a.5.5 0 0 0-.5-.5h-3A1.5 1.5 0 0 1 14 3.5m-12 2A3.5 3.5 0 0 1 5.5 2h3a1.5 1.5 0 1 1 0 3h-3a.5.5 0 0 0-.5.5v3a1.5 1.5 0 1 1-3 0zM3.5 14A1.5 1.5 0 0 1 5 15.5v3a.5.5 0 0 0 .5.5h3a1.5 1.5 0 0 1 0 3h-3A3.5 3.5 0 0 1 2 18.5v-3A1.5 1.5 0 0 1 3.5 14m17 0a1.5 1.5 0 0 1 1.5 1.5v3a3.5 3.5 0 0 1-3.5 3.5h-3a1.5 1.5 0 0 1 0-3h3a.5.5 0 0 0 .5-.5v-3a1.5 1.5 0 0 1 1.5-1.5" clip-rule="evenodd"/>
    </svg>;
}
