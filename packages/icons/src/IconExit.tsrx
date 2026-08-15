/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconExit(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M6.5 2A3.5 3.5 0 0 0 3 5.5v13A3.5 3.5 0 0 0 6.5 22H12a1.5 1.5 0 0 0 0-3H6.5a.5.5 0 0 1-.5-.5v-13a.5.5 0 0 1 .5-.5H12a1.5 1.5 0 0 0 0-3zm9.44 3.94a1.5 1.5 0 0 1 2.12 0l5 5a1.497 1.497 0 0 1 0 2.12l-5 5a1.5 1.5 0 0 1-2.12-2.12l2.439-2.44H11a1.5 1.5 0 0 1 0-3h7.379l-2.44-2.44a1.5 1.5 0 0 1 0-2.12" clip-rule="evenodd"/>
    </svg>;
}
