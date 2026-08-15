/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconLineChartStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M2 3a1 1 0 0 1 2 0v17h17a1 1 0 1 1 0 2H3a1 1 0 0 1-1-1zm18.382 3.47a1 1 0 0 0-1.764-.94l-3.512 6.583-5.102-2.977a1 1 0 0 0-1.368.36l-3.5 6a1 1 0 0 0 1.728 1.008l2.996-5.136 5.136 2.996a1 1 0 0 0 1.386-.393z" clip-rule="evenodd"/>
    </svg>;
}
