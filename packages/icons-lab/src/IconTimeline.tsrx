/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconTimeline(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="#AAB2BF" d="M3 11h18v2H3z"/><circle cx="4" cy="12" r="3" fill="#DDE3E8"/><circle cx="12" cy="12" r="3" fill="#DDE3E8"/><circle cx="20" cy="12" r="3" fill="#4CC3FA"/>
    </svg>;
}
