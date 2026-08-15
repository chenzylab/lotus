/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconVersionStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M5.125 3.125v17.027l6.358-3.288c.324-.167.71-.167 1.034 0l6.358 3.288V3.125zM2.875 3C2.875 1.826 3.826.875 5 .875h14c1.174 0 2.125.951 2.125 2.125v19a1.125 1.125 0 0 1-1.642 1L12 19.13 4.517 23a1.125 1.125 0 0 1-1.642-1z" clip-rule="evenodd"/><path fill="currentColor" fill-rule="evenodd" d="M6.875 9c0-.621.504-1.125 1.125-1.125h8a1.125 1.125 0 0 1 0 2.25H8A1.125 1.125 0 0 1 6.875 9" clip-rule="evenodd"/>
    </svg>;
}
