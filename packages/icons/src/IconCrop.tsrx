/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconCrop(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M21.5 19a1.5 1.5 0 0 0 0-3H19V8c0-1.5-1.5-3-3-3H8V2.5a1.5 1.5 0 1 0-3 0V5H2.5a1.5 1.5 0 1 0 0 3H5v8c0 1.5 1.5 3 3 3h8v2.5a1.5 1.5 0 0 0 3 0V19zM16 16V9a1 1 0 0 0-1-1H8v7a1 1 0 0 0 1 1z" clip-rule="evenodd"/>
    </svg>;
}
