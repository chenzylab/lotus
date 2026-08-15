/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconRingChartStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M20.945 13A9.001 9.001 0 1 1 11 3.055V7.1a5.002 5.002 0 0 0 1 9.9 5 5 0 0 0 4.9-4zm0-2H16.9A5.01 5.01 0 0 0 13 7.1V3.055A9.004 9.004 0 0 1 20.945 11M23 12c0 6.075-4.925 11-11 11S1 18.075 1 12 5.925 1 12 1s11 4.925 11 11m-8 0a3 3 0 1 1-6 0 3 3 0 0 1 6 0" clip-rule="evenodd"/>
    </svg>;
}
