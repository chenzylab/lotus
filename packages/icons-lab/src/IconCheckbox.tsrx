/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconCheckbox(props: { class?: string; style?: Record<string, any> }) {
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
        <rect width="20" height="20" x="1.009" y="3.1" fill="#4CC3FA" rx="3" transform="rotate(-6 1.01 3.1)"/><path stroke="#fff" stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="m8.074 12.915 3.35 3.168 4.24-7.485"/>
    </svg>;
}
