/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconFilpVertical(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M20.875 10.875a1.25 1.25 0 0 0 .444-2.418L3.57 1.707a1.25 1.25 0 0 0-1.694 1.168v6.75c0 .69.56 1.25 1.25 1.25zm-16.5-2.5V4.688l9.696 3.687zm17.73 5.524a1.25 1.25 0 0 0-1.23-1.024H3.125c-.69 0-1.25.56-1.25 1.25v6.75a1.25 1.25 0 0 0 1.694 1.168l17.75-6.75a1.25 1.25 0 0 0 .785-1.394" clip-rule="evenodd"/>
    </svg>;
}
