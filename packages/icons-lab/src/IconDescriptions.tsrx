/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconDescriptions(props: { class?: string; style?: Record<string, any> }) {
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
        <rect width="18.5" height="18.5" x="2.75" y="2.75" fill="#fff" stroke="#AAB2BF" stroke-width="1.5" rx="3"/><path fill="#AAB2BF" d="M5 6h4v2H5zM5 11h4v2H5zM5 16h2v2H5z"/><path fill="#324350" d="M11 11h4v2h-4zM11 16h8v2h-8zM11 6h8v2h-8z"/>
    </svg>;
}
