/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconMiniPlayer(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="M15.501 22a1.5 1.5 0 0 1-1.5-1.5v-5a1.5 1.5 0 0 1 1.5-1.5h5a1.5 1.5 0 0 1 1.5 1.5v5a1.5 1.5 0 0 1-1.5 1.5z"/><path fill="currentColor" d="M5.501 22a3.5 3.5 0 0 1-3.5-3.5v-13a3.5 3.5 0 0 1 3.5-3.5h13a3.5 3.5 0 0 1 3.5 3.5v4.25a1.5 1.5 0 0 1-3 0V5.5a.5.5 0 0 0-.5-.5h-13a.5.5 0 0 0-.5.5v13a.5.5 0 0 0 .5.5H9.75a1.5 1.5 0 0 1 0 3z"/><path fill="currentColor" fill-rule="evenodd" d="M7.52 7.187a1 1 0 0 0 0 1.414l2.95 2.95h-.828a1 1 0 1 0 0 2h3.242a1 1 0 0 0 1-1V9.308a1 1 0 1 0-2 0v.828l-2.95-2.95a1 1 0 0 0-1.414 0" clip-rule="evenodd"/>
    </svg>;
}
