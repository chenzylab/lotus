/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconCode(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M14.489 4.186a1.5 1.5 0 0 0-2.977-.372l-2 16a1.5 1.5 0 1 0 2.976.372zM8.06 5.939a1.5 1.5 0 0 1 0 2.122L4.12 12l3.94 3.94a1.5 1.5 0 1 1-2.122 2.12l-5-5a1.5 1.5 0 0 1 0-2.12l5-5a1.5 1.5 0 0 1 2.122 0m7.878 0a1.5 1.5 0 0 1 2.122 0l5 5a1.5 1.5 0 0 1 0 2.122l-5 5a1.5 1.5 0 0 1-2.122-2.122L19.88 12l-3.94-3.94a1.5 1.5 0 0 1 0-2.12" clip-rule="evenodd"/>
    </svg>;
}
