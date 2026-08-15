/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconExpand(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="M10 2a1.5 1.5 0 0 1 0 3H7.121l3.94 3.94a1.5 1.5 0 0 1-2.122 2.12L5 7.122V10a1.5 1.5 0 0 1-3 0V3.5A1.5 1.5 0 0 1 3.5 2zM19 14a1.5 1.5 0 0 1 3 0v6.5a1.5 1.5 0 0 1-1.5 1.5H14a1.5 1.5 0 0 1 0-3h2.879l-3.94-3.94a1.5 1.5 0 0 1 2.122-2.12L19 16.878z"/>
    </svg>;
}
