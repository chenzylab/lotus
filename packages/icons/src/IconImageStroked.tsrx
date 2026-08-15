/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconImageStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M2 4a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v16a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2zm18 0H4v16h16zM9 8a1 1 0 1 0 0 2 1 1 0 0 0 0-2M6 9a3 3 0 1 1 6 0 3 3 0 0 1-6 0m11.707 1.793a1 1 0 0 0-1.414 0l-3.867 3.867-1.801-1.44a1 1 0 0 0-1.332.073l-3.5 3.5a1 1 0 1 0 1.414 1.414l2.867-2.867 1.801 1.44a1 1 0 0 0 1.332-.073L17 12.914l.793.793a1 1 0 0 0 1.414-1.414z" clip-rule="evenodd"/>
    </svg>;
}
