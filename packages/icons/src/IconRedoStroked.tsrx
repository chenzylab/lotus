/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconRedoStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M3.5 12a8 8 0 0 1 13.657-5.657c.28.28.683.71 1.093 1.157H16a1 1 0 1 0 0 2h4.5a1 1 0 0 0 1-1V4a1 1 0 1 0-2 0v1.905a38 38 0 0 0-.929-.976A9.97 9.97 0 0 0 11.5 2c-5.523 0-10 4.477-10 10s4.477 10 10 10a9.97 9.97 0 0 0 7.071-2.929 1 1 0 1 0-1.414-1.414A8 8 0 0 1 3.5 12" clip-rule="evenodd"/>
    </svg>;
}
