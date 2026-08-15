/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconSearchStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M16 10a6 6 0 1 1-12 0 6 6 0 0 1 12 0m-1.094 6.32a8 8 0 1 1 1.414-1.414l5.387 5.387a1 1 0 0 1-1.414 1.414z" clip-rule="evenodd"/>
    </svg>;
}
