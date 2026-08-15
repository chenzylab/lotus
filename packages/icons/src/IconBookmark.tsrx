/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconBookmark(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="M4 21.586V3a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v18.586c0 .89-1.077 1.337-1.707.707L12 16l-6.293 6.293c-.63.63-1.707.184-1.707-.707"/>
    </svg>;
}
