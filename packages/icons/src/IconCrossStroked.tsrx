/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconCrossStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M3.616 19.116a1.25 1.25 0 0 0 1.768 1.768l7.116-7.116 7.116 7.116a1.25 1.25 0 0 0 1.768-1.768L14.268 12l7.116-7.116a1.25 1.25 0 0 0-1.768-1.768L12.5 10.232 5.384 3.116a1.25 1.25 0 1 0-1.768 1.768L10.732 12z" clip-rule="evenodd"/>
    </svg>;
}
