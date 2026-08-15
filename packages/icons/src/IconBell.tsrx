/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconBell(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="M18 9a6 6 0 0 0-3.007-5.201 3 3 0 0 0-5.986 0A6 6 0 0 0 6 9s0 2-.5 4c-.283 1.133-1.69 2.908-2.856 4.233-.588.67-.12 1.767.77 1.767h17.172c.89 0 1.358-1.098.77-1.767-1.167-1.325-2.573-3.1-2.856-4.233-.5-2-.5-4-.5-4M15 20a3 3 0 1 1-6 0z"/>
    </svg>;
}
