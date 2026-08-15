/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconChevronUp(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M19.637 16.437a1.5 1.5 0 0 1-2.121 0l-5.657-5.657-5.657 5.657a1.5 1.5 0 1 1-2.121-2.121l6.717-6.718a1.5 1.5 0 0 1 2.121 0l6.718 6.718a1.5 1.5 0 0 1 0 2.12" clip-rule="evenodd"/>
    </svg>;
}
