/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconGridRectangle(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M1 7a3 3 0 0 1 3-3h16a3 3 0 0 1 3 3v10a3 3 0 0 1-3 3H4a3 3 0 0 1-3-3zm9.5 0H5a1 1 0 0 0-1 1v2.5h6.5zm3 0v3.5H20V8a1 1 0 0 0-1-1zm6.5 6.5h-6.5V17H19a1 1 0 0 0 1-1zM10.5 17v-3.5H4V16a1 1 0 0 0 1 1z" clip-rule="evenodd"/>
    </svg>;
}
