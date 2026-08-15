/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconSideSheet(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="#DDE3E8" d="M2 5a3 3 0 0 1 3-3h9v20H5a3 3 0 0 1-3-3z"/><path fill="#4CC3FA" d="M14 2h5a3 3 0 0 1 3 3v14a3 3 0 0 1-3 3h-5z"/><rect width="2" height="8" x="11" y="8" fill="#AAB2BF" rx="1"/>
    </svg>;
}
