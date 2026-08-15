/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconList(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M4 6.5a2 2 0 1 0 0-4 2 2 0 0 0 0 4M9.5 3a1.5 1.5 0 1 0 0 3h11a1.5 1.5 0 0 0 0-3zM8 11.5A1.5 1.5 0 0 1 9.5 10h11a1.5 1.5 0 0 1 0 3h-11A1.5 1.5 0 0 1 8 11.5m0 7A1.5 1.5 0 0 1 9.5 17h11a1.5 1.5 0 0 1 0 3h-11A1.5 1.5 0 0 1 8 18.5m-2-7a2 2 0 1 1-4 0 2 2 0 0 1 4 0m-2 9a2 2 0 1 0 0-4 2 2 0 0 0 0 4" clip-rule="evenodd" opacity=".99"/>
    </svg>;
}
