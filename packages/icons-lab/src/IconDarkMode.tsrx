/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconDarkMode(props: { class?: string; style?: Record<string, any> }) {
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
        <circle cx="12" cy="12" r="11" fill="#324350"/><path fill="#FBCD2C" fill-rule="evenodd" d="M18 15.952q-.622.11-1.275.111a7.29 7.29 0 0 1-6.136-11.229A7.29 7.29 0 1 0 18 15.952" clip-rule="evenodd"/>
    </svg>;
}
