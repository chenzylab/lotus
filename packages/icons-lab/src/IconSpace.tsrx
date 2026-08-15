/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconSpace(props: { class?: string; style?: Record<string, any> }) {
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
        <rect width="2" height="20" x="1" y="2" fill="#DDE3E8" rx="1"/><rect width="2" height="20" x="21" y="2" fill="#DDE3E8" rx="1"/><path stroke="#4CC3FA" stroke-linecap="round" stroke-width="2" d="M6 12h12"/><path stroke="#4CC3FA" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m15 9 3 3-3 3M9 9l-3 3 3 3"/>
    </svg>;
}
