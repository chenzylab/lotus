/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconRotationStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M19 1.5a1 1 0 0 1 1 1v5h-5a1 1 0 1 1 0-2h1.604a8.003 8.003 0 0 0-10.78 11.55c.338.435.345 1.066-.046 1.456S4.75 18.9 4.4 18.472c-3.22-3.928-2.996-9.734.671-13.401C8.594 1.548 14.091 1.203 18 4.036V2.5a1 1 0 0 1 1-1M8 21a1 1 0 1 0 0-2 1 1 0 0 0 0 2m5 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0m3 0a1 1 0 1 0 0-2 1 1 0 0 0 0 2m4.5-3.5a1 1 0 1 1-2 0 1 1 0 0 1 2 0M21 14a1 1 0 1 0 0-2 1 1 0 0 0 0 2" clip-rule="evenodd"/>
    </svg>;
}
