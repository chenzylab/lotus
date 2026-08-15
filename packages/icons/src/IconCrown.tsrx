/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconCrown(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="M.83 7.659c-.239-.767.675-1.369 1.285-.846L3.97 8.402a3 3 0 0 0 4.683-1.037l2.438-5.362c.355-.782 1.465-.782 1.82 0l2.438 5.362a3 3 0 0 0 4.683 1.037l1.854-1.589c.61-.523 1.524.08 1.284.846l-3.73 12.938A2 2 0 0 1 17.529 22H6.47a2 2 0 0 1-1.909-1.403z"/>
    </svg>;
}
