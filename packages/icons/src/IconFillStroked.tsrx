/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconFillStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M7.415 2.172a1 1 0 0 1 1.415 0l9.434 9.435a1 1 0 0 1 0 1.414l-.023.022-6.695 6.695a2.5 2.5 0 0 1-3.535 0L2.354 14.08a2.5 2.5 0 0 1 0-3.535l6.01-6.01-.949-.95a1 1 0 0 1 0-1.414M9.778 5.95l6.364 6.364-2.186 2.187H5.6l-1.833-1.833a.5.5 0 0 1 0-.707zM21 19c0 1.105-.672 2-1.5 2s-1.5-.895-1.5-2c0-1.078.662-2.488 1.106-3.314a.441.441 0 0 1 .788 0C20.34 16.511 21 17.921 21 19" clip-rule="evenodd"/>
    </svg>;
}
