/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconMenu(props: { class?: string; style?: Record<string, any> }) {
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
        <g fill="currentColor" opacity=".99"><path d="M2 19.5A1.5 1.5 0 0 1 3.5 18h17a1.5 1.5 0 0 1 0 3h-17A1.5 1.5 0 0 1 2 19.5M2 12a1.5 1.5 0 0 1 1.5-1.5h17a1.5 1.5 0 0 1 0 3h-17A1.5 1.5 0 0 1 2 12M2 4.5A1.5 1.5 0 0 1 3.5 3h17a1.5 1.5 0 0 1 0 3h-17A1.5 1.5 0 0 1 2 4.5"/></g>
    </svg>;
}
