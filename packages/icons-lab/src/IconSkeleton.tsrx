/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconSkeleton(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="#DDE3E8" d="M2 11h21v3H2zM2 15h21v3H2z"/><path fill="#AAB2BF" d="M11 2h12v3H11zM11 6h9v3h-9z"/><path fill="#DDE3E8" d="M2 19h11v3H2z"/><path fill="#6A6F7F" d="M2 2h7v7H2z"/>
    </svg>;
}
