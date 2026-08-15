/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconFavoriteList(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M13.248 1.904C12.854.7 11.145.7 10.753 1.904L8.76 8.02H2.314c-1.27 0-1.799 1.622-.77 2.367l5.214 3.78-1.992 6.115c-.392 1.206.99 2.208 2.019 1.463L12 17.964V13a1 1 0 0 1 1-1h7.23l2.227-1.614c1.028-.745.5-2.367-.771-2.367h-6.447z" clip-rule="evenodd"/><path fill="currentColor" d="M14 14.5a.5.5 0 0 1 .5-.5h8a.5.5 0 0 1 .5.5v2a.5.5 0 0 1-.5.5h-8a.5.5 0 0 1-.5-.5zm0 5a.5.5 0 0 1 .5-.5h8a.5.5 0 0 1 .5.5v2a.5.5 0 0 1-.5.5h-8a.5.5 0 0 1-.5-.5z"/>
    </svg>;
}
