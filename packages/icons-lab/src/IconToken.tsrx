/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconToken(props: { class?: string; style?: Record<string, any> }) {
    return <svg
        viewBox="0 0 20 20"
        fill="none"
        width="1em"
        height="1em"
        class={props.class}
        style={props.style}
        aria-hidden={true}
        xmlns="http://www.w3.org/2000/svg"
    >
        <rect width="8" height="8" fill="#F0B114" rx="4"/><rect width="8" height="8" y="10" fill="#E91E63" rx="4"/><rect width="8" height="8" x="10" fill="#0077FA" rx="4"/><rect width="8" height="8" x="10" y="10" fill="#00B3A1" rx="4"/>
    </svg>;
}
