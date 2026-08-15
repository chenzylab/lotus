/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconDelete(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M9.38 2a1 1 0 0 0-.893.551L7.005 5.5H3a1 1 0 0 0-1 1v1a1 1 0 0 0 1 1h18a1 1 0 0 0 1-1v-1a1 1 0 0 0-1-1h-4.005l-1.482-2.949A1 1 0 0 0 14.619 2zm5.477 3.5-.713-1.248A.5.5 0 0 0 13.71 4h-3.42a.5.5 0 0 0-.434.252L9.143 5.5zM18.72 10H5.281a1 1 0 0 0-.97 1.242l2.12 8.486A3 3 0 0 0 9.343 22h5.316a3 3 0 0 0 2.91-2.272l2.121-8.486A1 1 0 0 0 18.72 10" clip-rule="evenodd"/>
    </svg>;
}
