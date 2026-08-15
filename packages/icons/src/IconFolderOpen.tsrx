/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconFolderOpen(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M2 5a3 3 0 0 1 3-3h3.298a2 2 0 0 1 1.25.438l1.13.905A3 3 0 0 0 12.552 4H18c2 0 3 2 3 4H7.534a2 2 0 0 0-1.932 1.481l-3.03 11.28A3 3 0 0 1 2 19zm20.167 5H9.5a2 2 0 0 0-1.92 1.44l-2.707 9.28a1 1 0 0 0 .96 1.28H18.5a2 2 0 0 0 1.92-1.44l2.707-9.28a1 1 0 0 0-.96-1.28" clip-rule="evenodd"/>
    </svg>;
}
