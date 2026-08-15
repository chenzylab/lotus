/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconLayout(props: { class?: string; style?: Record<string, any> }) {
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
        <rect width="20" height="20" x="2" y="2" fill="#DDE3E8" rx="3"/><path fill="#6A6F7F" d="M5 5h14v4H5z"/><path fill="#AAB2BF" d="M11 11h8v3h-8zM11 16h8v3h-8zM5 11h4v8H5z"/>
    </svg>;
}
