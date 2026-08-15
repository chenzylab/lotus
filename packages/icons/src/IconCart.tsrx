/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconCart(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M.5 4A1.5 1.5 0 0 1 2 2.5h3c.74 0 1.37.54 1.483 1.272L6.67 5h15.082a1 1 0 0 1 .977 1.217l-1.556 7a1 1 0 0 1-.976.783H8.056l.23 1.5H19a1.5 1.5 0 0 1 0 3H7a1.5 1.5 0 0 1-1.483-1.272L3.713 5.5H2A1.5 1.5 0 0 1 .5 4M9 23a2 2 0 1 0 0-4 2 2 0 0 0 0 4m9 0a2 2 0 1 0 0-4 2 2 0 0 0 0 4" clip-rule="evenodd"/>
    </svg>;
}
