/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconCrossCircleStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M23 12c0 6.075-4.925 11-11 11S1 18.075 1 12 5.925 1 12 1s11 4.925 11 11m-11 9a9 9 0 1 0 0-18 9 9 0 0 0 0 18M8.111 8.11a1 1 0 0 1 1.414 0L12 10.587l2.475-2.475a1 1 0 1 1 1.414 1.414L13.414 12l2.475 2.475a1 1 0 0 1-1.414 1.414L12 13.414 9.525 15.89a1 1 0 0 1-1.414-1.414L10.586 12 8.11 9.525a1 1 0 0 1 0-1.414" clip-rule="evenodd"/>
    </svg>;
}
