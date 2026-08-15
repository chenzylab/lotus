/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconTestScore(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="M19 1a2 2 0 0 1 2 2v18a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V3a2 2 0 0 1 2-2zM7 17.5a1 1 0 1 0 0 2h10a1 1 0 1 0 0-2zm0-4a1 1 0 1 0 0 2h10a1 1 0 1 0 0-2zM9.25 5a.75.75 0 0 0-.67.415l-2.5 5a.75.75 0 0 0 1.34.67l.419-.835h2.822l.418.835a.751.751 0 0 0 1.342-.67l-2.5-5A.75.75 0 0 0 9.25 5m.661 3.75H8.59l.661-1.323z"/>
    </svg>;
}
