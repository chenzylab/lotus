/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconFullScreenStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M11.207 11.207a1 1 0 0 1-1.414 0L4 5.414V9a1 1 0 1 1-2 0V2.997c0-.272.11-.518.286-.698l.013-.013A1 1 0 0 1 2.997 2H9a1 1 0 0 1 0 2H5.414l5.793 5.793a1 1 0 0 1 0 1.414m1.586 1.586a1 1 0 0 1 1.414 0L20 18.586V15a1 1 0 1 1 2 0v6.003c0 .272-.11.518-.286.698l-.013.013a1 1 0 0 1-.698.286H15a1 1 0 1 1 0-2h3.586l-5.793-5.793a1 1 0 0 1 0-1.414" clip-rule="evenodd"/>
    </svg>;
}
