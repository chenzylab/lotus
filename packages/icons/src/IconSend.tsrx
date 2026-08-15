/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconSend(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="M20.603 2.132 1.535 8.488a1 1 0 0 0-.39 1.656l3.812 3.813a1 1 0 0 0 1.208.158l8.186-4.74c.177-.102.376.097.273.274l-4.74 8.186a1 1 0 0 0 .16 1.208l3.812 3.813a1 1 0 0 0 1.656-.391l6.356-19.068a1 1 0 0 0-1.265-1.265"/>
    </svg>;
}
