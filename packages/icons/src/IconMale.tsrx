/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconMale(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M11.879 3.5a1.5 1.5 0 0 1 1.5-1.5h6.5a2.5 2.5 0 0 1 2.5 2.5V11a1.5 1.5 0 0 1-3 0V7.121l-3.937 4.037a7.5 7.5 0 1 1-2.025-2.22L17.257 5H13.38a1.5 1.5 0 0 1-1.5-1.5M4.5 15a4.5 4.5 0 1 1 9 0 4.5 4.5 0 0 1-9 0" clip-rule="evenodd"/>
    </svg>;
}
