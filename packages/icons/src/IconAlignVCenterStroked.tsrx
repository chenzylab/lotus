/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconAlignVCenterStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M18 3a1 1 0 0 1 1 1v7h2a1 1 0 1 1 0 2h-2v7a1 1 0 0 1-1 1h-4a1 1 0 0 1-1-1v-7h-2v4a1 1 0 0 1-1 1H6a1 1 0 0 1-1-1v-4H3a1 1 0 1 1 0-2h2V7a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v4h2V4a1 1 0 0 1 1-1zm-1 2h-2v14h2zM7 8h2v8H7z" clip-rule="evenodd"/>
    </svg>;
}
