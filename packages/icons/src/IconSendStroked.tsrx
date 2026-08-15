/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconSendStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="m9.468 13.116-4.11-2.74 13.103-4.913-5.22 13.05-2.385-3.974q.048-.037.092-.082l3.5-3.5a1 1 0 0 0-1.414-1.414l-3.5 3.5a1 1 0 0 0-.066.073M2.828 9.19l17.051-6.395c.814-.305 1.602.501 1.28 1.308l-6.81 17.025a1 1 0 0 1-1.786.143L8.99 15.318A1 1 0 0 0 8.688 15l-6.064-4.042a1 1 0 0 1 .204-1.768" clip-rule="evenodd"/>
    </svg>;
}
