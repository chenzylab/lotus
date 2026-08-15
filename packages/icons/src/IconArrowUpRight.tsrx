/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconArrowUpRight(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M5 4.5A1.5 1.5 0 0 1 6.5 3h13A1.5 1.5 0 0 1 21 4.5v13a1.5 1.5 0 0 1-3 0V8.121L4.56 21.561a1.5 1.5 0 1 1-2.12-2.122L15.878 6H6.5A1.5 1.5 0 0 1 5 4.5" clip-rule="evenodd"/>
    </svg>;
}
