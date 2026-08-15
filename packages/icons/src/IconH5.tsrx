/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconH5(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M3.5 2.5A1.5 1.5 0 0 1 5 4v6.5h6V4a1.5 1.5 0 0 1 3 0v16a1.5 1.5 0 0 1-3 0v-6.5H5V20a1.5 1.5 0 0 1-3 0V4a1.5 1.5 0 0 1 1.5-1.5" clip-rule="evenodd"/><path fill="currentColor" d="M15.16 19.059c0 1.182 1.599 2.146 3.52 2.146 2.454 0 3.985-1.333 3.985-3.473 0-1.859-1.217-3.076-3.062-3.076-.814 0-1.525.253-1.867.663h-.143l.096-1.435h3.288c.806 0 1.244-.39 1.244-1.094 0-.71-.445-1.121-1.244-1.121H17.06c-1.005 0-1.545.437-1.6 1.299l-.185 3.035c-.048.78.616 1.347 1.456 1.347.301 0 .602-.082.848-.233.424-.26.861-.41 1.217-.41.677 0 1.169.43 1.169 1.094 0 .697-.52 1.155-1.224 1.155-.506 0-.923-.212-1.449-.704-.308-.287-.615-.403-.998-.403-.704 0-1.135.56-1.135 1.21"/>
    </svg>;
}
