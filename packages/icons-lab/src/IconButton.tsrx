/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconButton(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="#6A6F7F" d="M2 16.5A2.5 2.5 0 0 1 4.5 14h15a2.5 2.5 0 0 1 0 5h-15A2.5 2.5 0 0 1 2 16.5"/><path fill="#DDE3E8" d="M8 12h8v2H8z"/><path fill="#F82C2C" d="M6 5.674c0-.939.654-1.746 1.584-1.873C8.662 3.654 10.214 3.5 12 3.5c1.785 0 3.338.154 4.416.3.93.128 1.584.935 1.584 1.874V11a1 1 0 0 1-1 1H7a1 1 0 0 1-1-1z"/>
    </svg>;
}
