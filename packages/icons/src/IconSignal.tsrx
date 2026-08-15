/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconSignal(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M20 3a1.5 1.5 0 0 0-1.5 1.5v16a1.5 1.5 0 0 0 3 0v-16A1.5 1.5 0 0 0 20 3m-7 5.5a1.5 1.5 0 0 1 3 0v12a1.5 1.5 0 0 1-3 0zM9 11a1.5 1.5 0 0 0-1.5 1.5v8a1.5 1.5 0 0 0 3 0v-8A1.5 1.5 0 0 0 9 11m-5.5 4A1.5 1.5 0 0 0 2 16.5v4a1.5 1.5 0 0 0 3 0v-4A1.5 1.5 0 0 0 3.5 15" clip-rule="evenodd"/>
    </svg>;
}
