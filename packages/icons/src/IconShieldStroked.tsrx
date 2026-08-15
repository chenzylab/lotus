/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconShieldStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path stroke="currentColor" stroke-linejoin="round" stroke-width="2" d="M3 4.128 12.001 2.5 21 4.128v5.389A13.16 13.16 0 0 1 12.001 22 13.16 13.16 0 0 1 3 9.514z"/><path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11.975 7.475v8M7.975 11.475h8"/>
    </svg>;
}
