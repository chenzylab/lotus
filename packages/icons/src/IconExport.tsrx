/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconExport(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="M11.079.816a1.5 1.5 0 0 1 1.842 0l4.5 3.5a1.5 1.5 0 0 1-1.842 2.368L13.5 5.067V7.5a1.5 1.5 0 0 1-3 0V5.067L8.42 6.684A1.5 1.5 0 0 1 6.58 4.316z"/><path fill="currentColor" d="M2 11a3 3 0 0 1 3-3h5.5v6.5a1.5 1.5 0 0 0 3 0V8H19a3 3 0 0 1 3 3v9a3 3 0 0 1-3 3H5a3 3 0 0 1-3-3z"/>
    </svg>;
}
