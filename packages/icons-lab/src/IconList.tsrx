/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconList(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="#0077FA" d="M2 4a1 1 0 0 1 1-1h3v5H3a1 1 0 0 1-1-1z"/><path fill="#4CC3FA" d="M8 3h13a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1H8z"/><path fill="#AAB2BF" d="M2 11a1 1 0 0 1 1-1h3v5H3a1 1 0 0 1-1-1z"/><path fill="#DDE3E8" d="M8 10h13a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1H8z"/><path fill="#AAB2BF" d="M2 18a1 1 0 0 1 1-1h3v5H3a1 1 0 0 1-1-1z"/><path fill="#DDE3E8" d="M8 17h13a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1H8z"/>
    </svg>;
}
