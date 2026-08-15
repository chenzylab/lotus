/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconPaperclip(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M18.273 4.273a2.64 2.64 0 0 0-3.732 0l-7.75 7.75a4.407 4.407 0 1 0 6.232 6.232l5.5-5.5a1.25 1.25 0 1 1 1.768 1.768l-5.5 5.5a6.907 6.907 0 1 1-9.768-9.768l7.75-7.75a5.139 5.139 0 1 1 7.268 7.268l-7.25 7.25a3.371 3.371 0 1 1-4.768-4.768l5.5-5.5a1.25 1.25 0 1 1 1.768 1.768l-5.5 5.5a.871.871 0 1 0 1.232 1.232l7.25-7.25a2.64 2.64 0 0 0 0-3.732" clip-rule="evenodd"/>
    </svg>;
}
