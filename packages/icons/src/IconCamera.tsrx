/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconCamera(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M7.447 3.106A2 2 0 0 1 9.237 2h5.527a2 2 0 0 1 1.789 1.106L17.5 5H20a3 3 0 0 1 3 3v10a3 3 0 0 1-3 3H4a3 3 0 0 1-3-3V8a3 3 0 0 1 3-3h2.5zM9 13a3 3 0 1 1 6 0 3 3 0 0 1-6 0m3-5a5 5 0 1 0 0 10 5 5 0 0 0 0-10" clip-rule="evenodd"/>
    </svg>;
}
