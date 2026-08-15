/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconOverflow(props: { class?: string; style?: Record<string, any> }) {
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
        <rect width="22" height="16" x="1" y="4" fill="#DDE3E8" rx="3"/><circle cx="6" cy="12" r="2" fill="#6A6F7F"/><circle cx="12" cy="12" r="2" fill="#6A6F7F"/><circle cx="18" cy="12" r="2" fill="#6A6F7F"/>
    </svg>;
}
