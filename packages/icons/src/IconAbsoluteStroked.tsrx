/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconAbsoluteStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M13.621 5.036a1 1 0 1 0 1.415-1.415l-2.329-2.328a1 1 0 0 0-1.414 0L8.964 3.62a1 1 0 0 0 1.415 1.415l.62-.622V11H4.415l.622-.622A1 1 0 1 0 3.62 8.964l-2.328 2.329a1 1 0 0 0 0 1.414l2.328 2.328a1 1 0 0 0 1.415-1.414L4.414 13H11v6.586l-.622-.621a1 1 0 0 0-1.414 1.414l2.329 2.328a1 1 0 0 0 1.414 0l2.328-2.328a1 1 0 0 0-1.414-1.414l-.621.62V13h6.585l-.62.62a1 1 0 0 0 1.413 1.415l2.329-2.328a1 1 0 0 0 0-1.415l-2.329-2.328a1 1 0 1 0-1.414 1.414l.622.622H13V4.414z" clip-rule="evenodd"/>
    </svg>;
}
