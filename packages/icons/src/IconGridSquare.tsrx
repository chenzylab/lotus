/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconGridSquare(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M4 1a3 3 0 0 0-3 3v16a3 3 0 0 0 3 3h16a3 3 0 0 0 3-3V4a3 3 0 0 0-3-3zm15 3a1 1 0 0 1 1 1v5.5h-6.5V4zm-8.5 0H5a1 1 0 0 0-1 1v5.5h6.5zM4 13.5V19a1 1 0 0 0 1 1h5.5v-6.5zm9.5 6.5H19a1 1 0 0 0 1-1v-5.5h-6.5z" clip-rule="evenodd"/>
    </svg>;
}
