/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconCommentStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="m4 17.9.942-.735L5 17.12a3 3 0 0 1 1.789-.592H20V5H4zM21 3H3a1 1 0 0 0-1 1v15.95a1 1 0 0 0 1.615.788l2.558-1.997a1 1 0 0 1 .616-.212H21a1 1 0 0 0 1-1V4a1 1 0 0 0-1-1M8 8a1 1 0 0 0 0 2h8a1 1 0 1 0 0-2zm-1 5a1 1 0 0 1 1-1h5a1 1 0 1 1 0 2H8a1 1 0 0 1-1-1" clip-rule="evenodd"/>
    </svg>;
}
