/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconTreeSelect(props: { class?: string; style?: Record<string, any> }) {
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
        <rect width="20" height="12" x="2" y="10" fill="#DDE3E8" rx="2"/><path fill="#AAB2BF" d="M8 13a1 1 0 0 1 1-1h10a1 1 0 0 1 1 1v1a1 1 0 0 1-1 1H9a1 1 0 0 1-1-1zM4 13a1 1 0 0 1 1-1h1a1 1 0 0 1 1 1v1a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1zM10 18a1 1 0 0 1 1-1h8a1 1 0 0 1 1 1v1a1 1 0 0 1-1 1h-8a1 1 0 0 1-1-1z"/><path fill="#3BCE4A" d="M2 4a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v2a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2z"/><path fill="#818A9B" d="M14 2h6a2 2 0 0 1 2 2v2a2 2 0 0 1-2 2h-6z"/><path fill="#fff" d="M18.416 6.076a.5.5 0 0 1-.832 0l-1.066-1.599a.5.5 0 0 1 .416-.777h2.132a.5.5 0 0 1 .416.777z"/>
    </svg>;
}
