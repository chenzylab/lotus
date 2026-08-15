/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconTable(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="#3BCE4A" d="M2 5a2 2 0 0 1 2-2h7v5H2zM13 3h7a2 2 0 0 1 2 2v3h-9z"/><path fill="#AAB2BF" d="M2 10h9v5H2z"/><path fill="#DDE3E8" d="M13 10h9v5h-9zM2 17h9v5H4a2 2 0 0 1-2-2z"/><path fill="#AAB2BF" d="M13 17h9v3a2 2 0 0 1-2 2h-7z"/>
    </svg>;
}
