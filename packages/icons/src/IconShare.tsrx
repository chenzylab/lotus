/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconShare(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="M17.5 2a3.5 3.5 0 1 1-2.495 5.953l-5.133 3.11a3.5 3.5 0 0 1 .024 1.782l5.225 3.088a3.5 3.5 0 1 1-1.018 1.72l-5.225-3.087a3.5 3.5 0 1 1-.07-5.197l5.258-3.186A3.5 3.5 0 0 1 17.5 2"/>
    </svg>;
}
