/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconTrueFalseStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M15.793 4.293a1 1 0 0 1 1.414 0L19 6.086l1.793-1.793a1 1 0 1 1 1.414 1.414L20.414 7.5l1.793 1.793a1 1 0 0 1-1.414 1.414L19 8.914l-1.793 1.793a1 1 0 0 1-1.414-1.414L17.586 7.5l-1.793-1.793a1 1 0 0 1 0-1.414m6.96 11.366a1 1 0 0 0-1.506-1.318l-2.796 3.196-1.244-1.244a1 1 0 0 0-1.414 1.414l2 2a1 1 0 0 0 1.46-.049zM1 5a1 1 0 0 1 1-1h11a1 1 0 0 1 1 1v5a1 1 0 0 1-1 1H2a1 1 0 0 1-1-1zm2 1v3h9V6zm-1 7a1 1 0 0 0-1 1v5a1 1 0 0 0 1 1h11a1 1 0 0 0 1-1v-5a1 1 0 0 0-1-1zm1 5v-3h9v3z" clip-rule="evenodd"/>
    </svg>;
}
