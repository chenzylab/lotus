/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconScrollList(props: { class?: string; style?: Record<string, any> }) {
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
        <rect width="18.5" height="18.5" x="2.75" y="2.75" fill="#fff" stroke="#AAB2BF" stroke-width="1.5" rx="3"/><path fill="#6A6F7F" d="M16 2h3a3 3 0 0 1 3 3v14a3 3 0 0 1-3 3h-3z"/><path fill="#4CC3FA" d="M3.5 7H16v5H3.5z"/><path fill="#DDE3E8" d="M3.5 17H16v3.5H5.5a2 2 0 0 1-2-2z"/><path fill="#AAB2BF" d="m19 4 1.298 2.25H17.7zM18.999 20.25 17.7 18h2.598z"/><rect width="2" height="6" x="18" y="8" fill="#DDE3E8" rx="1"/>
    </svg>;
}
