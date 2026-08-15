/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconSwitch(props: { class?: string; style?: Record<string, any> }) {
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
        <rect width="20" height="10" x="2" y="1" fill="#DDE3E8" rx="5"/><circle cx="7.5" cy="6" r="3.5" fill="#fff"/><rect width="20" height="10" x="2" y="13" fill="#3BCE4A" rx="5"/><circle cx="16.5" cy="18" r="3.5" fill="#fff"/>
    </svg>;
}
