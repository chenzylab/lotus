/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconGettingStarted(props: { class?: string; style?: Record<string, any> }) {
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
        <circle cx="12" cy="12" r="11" fill="#4CC3FA"/><path fill="#fff" d="M16.898 11.335a.925.925 0 0 1 0 1.33c-.578.58-1.6 1.487-3.187 2.51a23 23 0 0 1-3.527 1.88c-.643.27-1.32-.137-1.411-.828A33 33 0 0 1 8.5 12c0-1.749.144-3.24.273-4.226.09-.692.768-1.098 1.41-.829.85.356 2.088.951 3.528 1.88 1.587 1.024 2.61 1.93 3.187 2.51"/>
    </svg>;
}
