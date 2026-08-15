/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconFlowChartStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M7.5 3a1 1 0 0 1 1-1h7a1 1 0 0 1 1 1v4.5a1 1 0 0 1-1 1H13V11h4.5a1 1 0 0 1 1 1v3.5H21a1 1 0 0 1 1 1V21a1 1 0 0 1-1 1h-7a1 1 0 0 1-1-1v-4.5a1 1 0 0 1 1-1h2.5V13h-9v2.5H10a1 1 0 0 1 1 1V21a1 1 0 0 1-1 1H3a1 1 0 0 1-1-1v-4.5a1 1 0 0 1 1-1h2.5V12a1 1 0 0 1 1-1H11V8.5H8.5a1 1 0 0 1-1-1zm-1 14.5H4V20h5v-2.5zm11 0H15V20h5v-2.5zM9.5 4v2.5h5V4z" clip-rule="evenodd"/>
    </svg>;
}
