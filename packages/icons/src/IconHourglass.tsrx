/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconHourglass(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="M20 1a1 1 0 1 1 0 2h-1v5a1 1 0 0 1-.293.707L15.414 12l3.293 3.293A1 1 0 0 1 19 16v5h1a1 1 0 1 1 0 2H4a1 1 0 1 1 0-2h1v-5a1 1 0 0 1 .293-.707L8.586 12 5.293 8.707A1 1 0 0 1 5 8V3H4a1 1 0 0 1 0-2zM9 18a1 1 0 1 0 0 2h6a1 1 0 1 0 0-2zm1-12a1 1 0 0 0 0 2h4a1 1 0 1 0 0-2z"/>
    </svg>;
}
