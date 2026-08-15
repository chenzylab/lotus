/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconMicrophone(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="M7.5 5.5a4.5 4.5 0 0 1 9 0v6a4.5 4.5 0 1 1-9 0z"/><path fill="currentColor" d="M5 10.5a1 1 0 0 1 1 1 6 6 0 0 0 12 0 1 1 0 1 1 2 0 8 8 0 1 1-16 0 1 1 0 0 1 1-1M8 21a1 1 0 1 0 0 2h8a1 1 0 1 0 0-2z"/>
    </svg>;
}
