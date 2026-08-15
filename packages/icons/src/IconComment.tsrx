/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconComment(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M23 11.5C23 5.701 18.299 1 12.5 1S2 5.701 2 11.5c0 1.918.514 3.716 1.412 5.263L2.087 20.74a1 1 0 0 0 1.206 1.283l4.414-1.177A10.46 10.46 0 0 0 12.5 22C18.299 22 23 17.299 23 11.5M7.5 13a1.5 1.5 0 1 1 0-3 1.5 1.5 0 0 1 0 3m6.5-1.5a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0m3.5 1.5a1.5 1.5 0 1 1 0-3 1.5 1.5 0 0 1 0 3" clip-rule="evenodd"/>
    </svg>;
}
