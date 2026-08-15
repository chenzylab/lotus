/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconFlipHorizontal(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M11 3a1.25 1.25 0 0 0-2.418-.444l-6.75 17.75A1.25 1.25 0 0 0 3 22h6.75c.69 0 1.25-.56 1.25-1.25zM8.5 19.5H4.813L8.5 9.804z" clip-rule="evenodd"/><path fill="currentColor" d="M14.024 1.77A1.25 1.25 0 0 0 13 3v17.75c0 .69.56 1.25 1.25 1.25H21a1.25 1.25 0 0 0 1.168-1.694l-6.75-17.75a1.25 1.25 0 0 0-1.394-.785"/>
    </svg>;
}
