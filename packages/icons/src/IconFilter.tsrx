/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconFilter(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M1.093 2.58A1 1 0 0 1 2 2h20a1 1 0 0 1 .764 1.646l-8.199 9.18V21a1 1 0 0 1-1.447.894l-3.065-2A1 1 0 0 1 9.5 19v-6.174l-8.264-9.18a1 1 0 0 1-.143-1.067" clip-rule="evenodd"/>
    </svg>;
}
