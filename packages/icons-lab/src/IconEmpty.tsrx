/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconEmpty(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="#AAB2BF" d="M5.441 9.083A2 2 0 0 1 7.22 8h9.561a2 2 0 0 1 1.778 1.084l3.376 6.553-19.805-.13z"/><path fill="#6A6F7F" d="M6.73 11.317a1 1 0 0 1 .905-.575h8.73a1 1 0 0 1 .905.575L19 15H5z"/><path fill="#DDE3E8" d="M2 16a1 1 0 0 1 1-1h18a1 1 0 0 1 1 1v5a1 1 0 0 1-1 1H3a1 1 0 0 1-1-1z"/><rect width="2" height="5" x="11" y="1" fill="#AAB2BF" rx="1"/><rect width="2" height="4.345" x="3.879" y="4.293" fill="#AAB2BF" rx="1" transform="rotate(-45 3.879 4.293)"/><rect width="2" height="4.218" x="18.573" y="2.879" fill="#AAB2BF" rx="1" transform="rotate(45 18.573 2.879)"/><circle cx="12" cy="18.5" r="1.5" fill="#AAB2BF"/>
    </svg>;
}
