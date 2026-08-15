/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconFixedStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M4 12a8 8 0 1 1 16 0 8 8 0 0 1-16 0m8-10a9.96 9.96 0 0 0-6.329 2.257L4.307 2.893a1 1 0 0 0-1.415 1.414L4.258 5.67A9.96 9.96 0 0 0 2 12c0 2.401.846 4.605 2.257 6.329l-1.364 1.364a1 1 0 1 0 1.414 1.415l1.365-1.365A9.96 9.96 0 0 0 12 22a9.96 9.96 0 0 0 6.328-2.257l1.365 1.365a1 1 0 0 0 1.414-1.415l-1.364-1.364A9.96 9.96 0 0 0 22 12a9.96 9.96 0 0 0-2.257-6.328l1.365-1.365a1 1 0 0 0-1.415-1.414L18.33 4.257A9.96 9.96 0 0 0 12 2m-2 10a2 2 0 1 1 4 0 2 2 0 0 1-4 0m2-4a4 4 0 1 0 0 8 4 4 0 0 0 0-8" clip-rule="evenodd"/>
    </svg>;
}
