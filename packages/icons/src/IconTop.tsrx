/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconTop(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M4 2a1 1 0 0 0-1 1v2a1 1 0 0 0 1 1h6.182L2.76 14.164a.5.5 0 0 0 .37.836H8v6a1 1 0 0 0 1 1h6a1 1 0 0 0 1-1v-6h4.87a.5.5 0 0 0 .37-.836L13.818 6H20a1 1 0 0 0 1-1V3a1 1 0 0 0-1-1z" clip-rule="evenodd"/>
    </svg>;
}
