/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconFolder(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="M5 2a3 3 0 0 0-3 3v3h20c0-2-1-4-3-4h-6.448a3 3 0 0 1-1.874-.657l-1.13-.905A2 2 0 0 0 8.298 2zM22 10H2v9a3 3 0 0 0 3 3h14a3 3 0 0 0 3-3z"/>
    </svg>;
}
