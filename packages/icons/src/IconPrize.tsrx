/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconPrize(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M4 1a1 1 0 0 0-1 1v5a1 1 0 0 0 .4.8L7 10.5v.601a7 7 0 1 0 10 0V10.5l3.6-2.7A1 1 0 0 0 21 7V2a1 1 0 0 0-1-1H4m3 15c0-1.48.642-2.81 1.666-3.727A4.98 4.98 0 0 1 12 11c1.281 0 2.448.48 3.333 1.273A5 5 0 1 1 7 16m2-6.326A7 7 0 0 1 12 9c1.073 0 2.09.242 3 .674V3H9zM15 16a3 3 0 1 1-6 0 3 3 0 0 1 6 0" clip-rule="evenodd"/>
    </svg>;
}
