/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconModal(props: { class?: string; style?: Record<string, any> }) {
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
        <rect width="20" height="20" x="2" y="2" fill="#AAB2BF" rx="3"/><rect width="16" height="12" x="4" y="6" fill="#fff" rx="1"/><rect width="5" height="3" x="6" y="13" fill="#AAB2BF" rx="1"/><rect width="5" height="3" x="13" y="13" fill="#4CC3FA" rx="1"/>
    </svg>;
}
