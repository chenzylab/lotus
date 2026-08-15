/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconVersionOne(props: { class?: string; style?: Record<string, any> }) {
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
        <rect width="20" height="20" x="2" y="2" fill="#4CC3FA" rx="3"/><path fill="#fff" d="M8.325 8.273H6.821L4.652 9.666v1.45L6.693 9.81h.051V17h1.581zm2.703 8.82a.95.95 0 0 0 .938-.937.947.947 0 0 0-.938-.929.93.93 0 0 0-.937.93.93.93 0 0 0 .937.937m5.4.073c2.104.005 3.361-1.658 3.361-4.521 0-2.847-1.265-4.492-3.362-4.492-2.096 0-3.358 1.641-3.362 4.492 0 2.86 1.257 4.521 3.362 4.521m0-1.334c-1.087 0-1.77-1.09-1.765-3.187.004-2.08.682-3.175 1.764-3.175 1.087 0 1.764 1.095 1.769 3.175 0 2.097-.678 3.187-1.769 3.187"/>
    </svg>;
}
