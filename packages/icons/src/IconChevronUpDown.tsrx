/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconChevronUpDown(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="M6.69 6.682a1.5 1.5 0 1 0 2.12 2.121l3.183-3.182 3.182 3.182a1.5 1.5 0 1 0 2.12-2.121l-4.242-4.243a1.5 1.5 0 0 0-2.121 0zM17.296 17.318a1.5 1.5 0 0 0-2.121-2.121l-3.182 3.182-3.182-3.182a1.5 1.5 0 1 0-2.122 2.121l4.243 4.243a1.5 1.5 0 0 0 2.121 0z"/>
    </svg>;
}
