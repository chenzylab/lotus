/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconMoreStroked(props: { class?: string; style?: Record<string, any> }) {
    return <svg
        viewBox="0 0 25 24"
        fill="none"
        width="1em"
        height="1em"
        class={props.class}
        style={props.style}
        aria-hidden={true}
        xmlns="http://www.w3.org/2000/svg"
    >
        <path fill="currentColor" d="M7.5 12a2.5 2.5 0 1 1-5 0 2.5 2.5 0 0 1 5 0M15 12a2.5 2.5 0 1 1-5 0 2.5 2.5 0 0 1 5 0M20 14.5a2.5 2.5 0 1 0 0-5 2.5 2.5 0 0 0 0 5"/>
    </svg>;
}
