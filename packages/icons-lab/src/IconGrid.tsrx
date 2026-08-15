/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconGrid(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="#6A6F7F" fill-rule="evenodd" d="M22 2H2v20h20zm-2 2H4v16h16z" clip-rule="evenodd"/><path fill="#DDE3E8" fill-rule="evenodd" d="M22 9h-2v6h2zM2 15h2V9H2zM15 22v-2H9v2zM9 2v2h6V2z" clip-rule="evenodd"/><path fill="#6A6F7F" d="M7 7h3v3H7z"/><path fill="#DDE3E8" d="M7 10h3v4H7zM14 10h3v4h-3zM10 7h4v3h-4zM10 14h4v3h-4z"/><path fill="#6A6F7F" d="M14 7h3v3h-3zM7 14h3v3H7zM14 14h3v3h-3z"/>
    </svg>;
}
