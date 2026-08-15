/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconAlignJustify(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M3.364 3C2.61 3 2 3.672 2 4.5S2.61 6 3.364 6h17.272C21.39 6 22 5.328 22 4.5S21.39 3 20.636 3zm0 5C2.61 8 2 8.672 2 9.5S2.61 11 3.364 11h17.272C21.39 11 22 10.328 22 9.5S21.39 8 20.636 8zM2 14.5c0-.828.61-1.5 1.364-1.5h17.272c.754 0 1.364.672 1.364 1.5s-.61 1.5-1.364 1.5H3.364C2.61 16 2 15.328 2 14.5M3.364 18C2.61 18 2 18.672 2 19.5S2.61 21 3.364 21h17.272C21.39 21 22 20.328 22 19.5s-.61-1.5-1.364-1.5z" clip-rule="evenodd"/>
    </svg>;
}
