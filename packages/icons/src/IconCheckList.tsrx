/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconCheckList(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M7.707 2.293a1 1 0 0 0-1.414 0L4 4.586 2.707 3.293a1 1 0 0 0-1.414 1.414l2 2a1 1 0 0 0 1.414 0l3-3a1 1 0 0 0 0-1.414M10.5 3a1.5 1.5 0 1 0 0 3h10a1.5 1.5 0 0 0 0-3zM9 11.5a1.5 1.5 0 0 1 1.5-1.5h10a1.5 1.5 0 0 1 0 3h-10A1.5 1.5 0 0 1 9 11.5m0 7a1.5 1.5 0 0 1 1.5-1.5h10a1.5 1.5 0 0 1 0 3h-10A1.5 1.5 0 0 1 9 18.5M6.293 9.293a1 1 0 0 1 1.414 1.414l-3 3a1 1 0 0 1-1.414 0l-2-2a1 1 0 1 1 1.414-1.414L4 11.586zm1.414 7a1 1 0 0 0-1.414 0L4 18.586l-1.293-1.293a1 1 0 0 0-1.414 1.414l2 2a1 1 0 0 0 1.414 0l3-3a1 1 0 0 0 0-1.414" clip-rule="evenodd" opacity=".99"/>
    </svg>;
}
