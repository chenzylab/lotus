/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconStar(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="M10.753 1.904c.392-1.205 2.102-1.205 2.495 0L15.24 8.02h6.446c1.27 0 1.799 1.622.77 2.367l-5.214 3.78 1.992 6.115c.392 1.206-.99 2.208-2.019 1.463L12 17.964l-5.215 3.78c-1.028.745-2.411-.257-2.019-1.463l1.992-6.115-5.215-3.78c-1.028-.745-.5-2.367.771-2.367H8.76z"/>
    </svg>;
}
