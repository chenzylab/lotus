/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconMuteStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="M10.375 2.219A1.002 1.002 0 0 1 12 3v18a1 1 0 0 1-1.625.781L4.649 17H2a1 1 0 0 1-1-1V8a1 1 0 0 1 1-1h2.65zM5.931 8.535A2 2 0 0 1 4.648 9H3v6h1.648c.469 0 .923.165 1.283.465L10 18.862V5.137zm14.14-.828a1 1 0 0 1 1.414 1.414l-2.475 2.475 2.475 2.475a1 1 0 1 1-1.414 1.414l-2.475-2.475-2.475 2.475a1 1 0 0 1-1.414-1.414l2.475-2.475-2.475-2.475a1 1 0 0 1 1.414-1.414l2.475 2.475z"/>
    </svg>;
}
