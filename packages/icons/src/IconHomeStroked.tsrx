/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconHomeStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M11.386 2.21a1 1 0 0 1 1.228 0l9 7A1 1 0 0 1 22 10v11a1 1 0 0 1-1 1h-6a1 1 0 0 1-1-1v-7h-4v7a1 1 0 0 1-1 1H3a1 1 0 0 1-1-1V10a1 1 0 0 1 .386-.79zM4 10.49V20h4v-7a1 1 0 0 1 1-1h6a1 1 0 0 1 1 1v7h4v-9.51l-8-6.223z" clip-rule="evenodd"/>
    </svg>;
}
