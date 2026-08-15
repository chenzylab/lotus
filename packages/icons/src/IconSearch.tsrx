/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconSearch(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M10.5 2a8.5 8.5 0 1 0 4.856 15.477l4.083 4.084a1.5 1.5 0 1 0 2.122-2.122l-4.084-4.083A8.5 8.5 0 0 0 10.5 2M5 10.5a5.5 5.5 0 1 1 11 0 5.5 5.5 0 0 1-11 0" clip-rule="evenodd"/>
    </svg>;
}
