/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconImage(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M5 2a3 3 0 0 0-3 3v14a3 3 0 0 0 3 3h14a3 3 0 0 0 3-3V5a3 3 0 0 0-3-3zm5 5.5a2.5 2.5 0 1 1-5 0 2.5 2.5 0 0 1 5 0m6.707 4.207a1 1 0 0 0-1.414 0L11 16l-1.293-1.293a1 1 0 0 0-1.414 0L5 18v1h14v-5z" clip-rule="evenodd"/>
    </svg>;
}
