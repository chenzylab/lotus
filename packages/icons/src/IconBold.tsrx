/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconBold(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M6 3a1 1 0 0 1 1-1h5.5c3.232 0 6 2.495 6 5.75a5.57 5.57 0 0 1-1.515 3.821c1.508 1.03 2.515 2.716 2.515 4.679 0 3.255-2.768 5.75-6 5.75H7a1 1 0 0 1-1-1zm7 16c1.739 0 3-1.31 3-2.75s-1.261-2.75-3-2.75H9V19zm-1-8.5c1.739 0 3-1.31 3-2.75S13.739 5 12 5H9v5.5z" clip-rule="evenodd"/>
    </svg>;
}
