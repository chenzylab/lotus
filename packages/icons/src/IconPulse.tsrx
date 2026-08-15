/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconPulse(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M9.5 1a1.5 1.5 0 0 1 1.407 1.098l3.762 14.268 1.408-4.84a1.5 1.5 0 0 1 1.423-1.027H22a1.5 1.5 0 0 1 0 3h-3.419l-2.62 8.476a1.5 1.5 0 0 1-2.868-.073L9.33 7.634l-1.408 4.84A1.5 1.5 0 0 1 6.5 13.499L2 13.5a1.5 1.5 0 0 1 0-3h3.419l2.62-8.475A1.5 1.5 0 0 1 9.5 1" clip-rule="evenodd"/>
    </svg>;
}
