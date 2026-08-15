/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconAlignHCenterStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M11 3a1 1 0 1 1 2 0v2h7a1 1 0 0 1 1 1v4a1 1 0 0 1-1 1h-7v2h4a1 1 0 0 1 1 1v4a1 1 0 0 1-1 1h-4v2a1 1 0 1 1-2 0v-2H7a1 1 0 0 1-1-1v-4a1 1 0 0 1 1-1h4v-2H4a1 1 0 0 1-1-1V6a1 1 0 0 1 1-1h7zm1 14h4v-2H8v2zm7-8H5V7h14z" clip-rule="evenodd"/>
    </svg>;
}
