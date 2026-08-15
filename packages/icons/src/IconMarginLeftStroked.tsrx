/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconMarginLeftStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M16 2a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h4a2 2 0 0 0 2-2V4a2 2 0 0 0-2-2zm0 2h4v16h-4zm-5.586 11.293A1 1 0 0 1 9 13.879l.586-.586H4.414l.586.586a1 1 0 1 1-1.414 1.414L1.293 13a1 1 0 0 1 0-1.414l2.293-2.293A1 1 0 0 1 5 10.707l-.586.586h5.172L9 10.707a1 1 0 1 1 1.414-1.414l2.293 2.293a1 1 0 0 1 0 1.414z" clip-rule="evenodd"/>
    </svg>;
}
