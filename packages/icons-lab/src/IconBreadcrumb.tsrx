/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconBreadcrumb(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="#AAB2BF" d="M6 4h8l4.006 6.41a3 3 0 0 1 0 3.18L14 20H6z"/><path fill="#6A6F7F" d="M2 7a3 3 0 0 1 3-3h2l4.006 6.41a3 3 0 0 1 0 3.18L7 20H5a3 3 0 0 1-3-3z"/><path fill="#DDE3E8" d="M13 20h3.337a3 3 0 0 0 2.544-1.41l3.125-5a3 3 0 0 0 0-3.18l-3.125-5A3 3 0 0 0 16.337 4H13l4.006 6.41a3 3 0 0 1 0 3.18z"/>
    </svg>;
}
