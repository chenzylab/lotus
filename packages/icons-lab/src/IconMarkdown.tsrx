/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconMarkdown(props: { class?: string; style?: Record<string, any> }) {
    return <svg
        viewBox="0 0 22 18"
        fill="none"
        width="1em"
        height="1em"
        class={props.class}
        style={props.style}
        aria-hidden={true}
        xmlns="http://www.w3.org/2000/svg"
    >
        <path fill="#6A6F7F" d="M0 14h22v2a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2z"/><path fill="#DDE3E8" d="M0 2a2 2 0 0 1 2-2h18a2 2 0 0 1 2 2v12H0z"/><rect width="2" height="2" x="18" y="15" fill="#DDE3E8" opacity=".5" rx="1"/><path fill="#6A6F7F" d="M3 5h5v1.5H3zM3 9h7v1.5H3z"/><rect width="7" height="7" x="12" y="4" fill="#F8CE27" rx="1"/>
    </svg>;
}
