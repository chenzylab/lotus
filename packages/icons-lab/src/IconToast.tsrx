/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconToast(props: { class?: string; style?: Record<string, any> }) {
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
        <g clip-path="url(#a)"><path fill="#FBCD2C" d="M.818 4.546C.412 5.002.354 5.93.42 6.557l.34 3.233c.108 1.03.981 1.782 1.95 1.68l.235-.025.901 8.578c.196 1.865 1.295 2.755 3.284 2.546l10.94-1.15c2.984-.314 3.874-1.413 3.678-3.278l-.902-8.577c.97-.102 1.901-1.044 1.793-2.074l-.34-3.232c-.084-.807-.41-1.464-1.082-1.858C19.87 1.612 16.25.496 10.902 1.058 5.343 1.642 1.727 3.523.818 4.545"/><circle cx="7.211" cy="8.987" r="1.5" fill="#324350" transform="rotate(-6 7.211 8.987)"/><circle cx="16.162" cy="8.046" r="1.5" fill="#324350" transform="rotate(-6 16.162 8.046)"/><path fill="#324350" d="M12.47 15.975a4 4 0 0 0 3.56-4.396s-1.046-.393-4.03-.079-3.926.915-3.926.915a4 4 0 0 0 4.396 3.56"/><path fill="#FF2969" fill-rule="evenodd" d="M14.673 15.02a4 4 0 0 1-2.203.955 4 4 0 0 1-2.353-.476 2.401 2.401 0 0 1 4.556-.48" clip-rule="evenodd"/></g><defs><clipPath id="a"><path fill="#fff" d="M0 0h24v24H0z"/></clipPath></defs>
    </svg>;
}
