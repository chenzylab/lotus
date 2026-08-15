/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconBookStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M5 4.999C5 3.894 5.894 3 6.998 3H19v14H6c-.35 0-.687.06-1 .17zM3 20V4.999A3.997 3.997 0 0 1 6.998 1H19a2 2 0 0 1 2 2v19a1 1 0 0 1-1 1H6a3 3 0 0 1-3-3m2 0a1 1 0 0 1 1-1h13v2H6a1 1 0 0 1-1-1" clip-rule="evenodd"/>
    </svg>;
}
