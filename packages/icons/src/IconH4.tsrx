/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconH4(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M3.5 2.5A1.5 1.5 0 0 1 5 4v6.5h6V4a1.5 1.5 0 0 1 3 0v16a1.5 1.5 0 0 1-3 0v-6.5H5V20a1.5 1.5 0 0 1-3 0V4a1.5 1.5 0 0 1 1.5-1.5" clip-rule="evenodd"/><path fill="currentColor" d="M19.083 19.68c0 .869.513 1.422 1.32 1.422.813 0 1.34-.56 1.34-1.421v-.082h.054c.677 0 1.094-.417 1.094-1.08 0-.67-.431-1.135-1.094-1.135h-.055V13.31c0-1.094-.889-1.798-2.27-1.798-1.073 0-1.722.41-2.563 1.613-.683.984-1.6 2.625-2.071 3.712-.273.636-.356.93-.356 1.32 0 .929.534 1.442 1.49 1.442h3.111zm-2.071-2.296v-.028c.15-.341 1.64-3.096 1.941-3.602h.13v3.63z"/>
    </svg>;
}
