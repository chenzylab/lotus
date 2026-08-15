/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconHash(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="m5.1 18-.597 2.17a1.446 1.446 0 0 0 2.79.767L8.1 18h4l-.597 2.17a1.446 1.446 0 0 0 2.79.767L15.1 18h4.4a1.5 1.5 0 0 0 0-3h-3.575l1.65-6H20.5a1.5 1.5 0 0 0 0-3h-2.1l.597-2.17a1.446 1.446 0 1 0-2.79-.767L15.4 6h-4l.597-2.17a1.446 1.446 0 1 0-2.79-.767L8.4 6H4.5a1.5 1.5 0 1 0 0 3h3.075l-1.65 6H3.5a1.5 1.5 0 0 0 0 3zm3.825-3 1.65-6h4l-1.65 6z" clip-rule="evenodd"/>
    </svg>;
}
