/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconH7(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M3.5 2.5A1.5 1.5 0 0 1 5 4v6.5h6V4a1.5 1.5 0 0 1 3 0v16a1.5 1.5 0 0 1-3 0v-6.5H5V20a1.5 1.5 0 0 1-3 0V4a1.5 1.5 0 0 1 1.5-1.5" clip-rule="evenodd"/><path fill="currentColor" d="M16.793 19.817c0 .766.54 1.285 1.34 1.285.54 0 .916-.26 1.217-.827l2.795-5.318c.431-.82.588-1.333.588-1.948 0-.793-.58-1.34-1.428-1.34h-4.656c-.8 0-1.305.437-1.305 1.121 0 .677.499 1.094 1.305 1.094h3.186v.027l-2.816 5.154q-.225.413-.226.752"/>
    </svg>;
}
