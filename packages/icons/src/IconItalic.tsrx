/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconItalic(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M9 3.5A1.5 1.5 0 0 1 10.5 2h7a1.5 1.5 0 0 1 0 3h-2L12 19h1.5a1.5 1.5 0 0 1 0 3h-7a1.5 1.5 0 0 1 0-3h2L12 5h-1.5A1.5 1.5 0 0 1 9 3.5" clip-rule="evenodd"/>
    </svg>;
}
