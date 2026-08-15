/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconColorPlatte(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="#DDE3E8" stroke="#DDE3E8" stroke-width="1.5" d="M12 2C6.478 2 2 6.478 2 12s4.478 10 10 10a1.664 1.664 0 0 0 1.233-2.783 1.65 1.65 0 0 1-.416-1.106c0-.922.744-1.667 1.666-1.667h1.961A5.56 5.56 0 0 0 22 10.89C22 5.978 17.522 2 12 2Z"/><circle cx="6" cy="12" r="2" fill="#F82C2C"/><circle cx="10.5" cy="7" r="2" fill="#4CC3FA"/><circle cx="17" cy="9" r="2" fill="#3BCE4A"/>
    </svg>;
}
