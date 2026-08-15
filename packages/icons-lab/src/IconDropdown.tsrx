/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconDropdown(props: { class?: string; style?: Record<string, any> }) {
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
        <rect width="20" height="20" x="1.009" y="3.1" fill="#6A6F7F" rx="3" transform="rotate(-6 1.01 3.1)"/><path fill="#fff" fill-rule="evenodd" d="M5.653 9.59a1.5 1.5 0 0 1 2.11-.222l4.329 3.506 3.506-4.33a1.5 1.5 0 0 1 2.331 1.888l-4.45 5.496a1.5 1.5 0 0 1-2.11.221L5.875 11.7a1.5 1.5 0 0 1-.221-2.11" clip-rule="evenodd"/>
    </svg>;
}
