/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconPincode(props: { class?: string; style?: Record<string, any> }) {
    return <svg
        viewBox="0 0 22 16"
        fill="none"
        width="1em"
        height="1em"
        class={props.class}
        style={props.style}
        aria-hidden={true}
        xmlns="http://www.w3.org/2000/svg"
    >
        <rect width="22" height="16" fill="#4CC3FA" rx="2"/><rect width="16" height="8" x="3" y="4" fill="#fff" rx="1"/><circle cx="6.5" cy="8" r="1" fill="#4CC3FA"/><circle cx="9.5" cy="8" r="1" fill="#4CC3FA"/><circle cx="12.5" cy="8" r="1" fill="#4CC3FA"/><circle cx="15.5" cy="8" r="1" fill="#4CC3FA"/><path stroke="#F8CE27" stroke-linecap="square" stroke-linejoin="round" stroke-width="1.5" d="M3 7V4.5a.5.5 0 0 1 .5-.5H6M19 9v2.5a.5.5 0 0 1-.5.5H16"/>
    </svg>;
}
