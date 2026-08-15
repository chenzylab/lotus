/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconHighlight(props: { class?: string; style?: Record<string, any> }) {
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
        <rect width="18" height="8" x="3" y="8" fill="#FAC800" rx="1"/><path fill="#6A6F7F" stroke="#6A6F7F" stroke-width=".4" d="M4.443 4.443a.96.96 0 0 0-.282.682v3.056a.964.964 0 0 0 1.928 0V6.089h4.947V17.91H8.944a.964.964 0 0 0-.681 1.646l.141-.142-.141.142c.18.18.426.282.681.282h6.112a.964.964 0 0 0 0-1.928h-2.092V6.09h4.947V8.18a.964.964 0 0 0 1.928 0V5.125a.964.964 0 0 0-.964-.964H5.125c-.256 0-.5.102-.682.282Z"/>
    </svg>;
}
