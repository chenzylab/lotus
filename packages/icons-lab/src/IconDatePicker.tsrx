/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconDatePicker(props: { class?: string; style?: Record<string, any> }) {
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
        <g clip-path="url(#a)"><rect width="22" height="16" x="1" y="4" fill="#DDE3E8" rx="3"/><path fill="#4CC3FA" d="M6.5 11H9v2.5H6.5zm6 4.5h-7V10h7zm0-8H12v-1h-1v1H7v-1H6v1h-.5a1 1 0 0 0-1 1v7c0 .55.45 1 1 1h7c.55 0 1-.45 1-1v-7c0-.55-.45-1-1-1"/><path fill="#fff" fill-rule="evenodd" d="M13.5 12.793c0-.891 1.077-1.337 1.707-.707l8.707 8.707c.63.63.184 1.707-.707 1.707H19.25a2 2 0 0 0-1.49.666l-2.514 2.81c-.612.684-1.745.25-1.745-.667zM17.684 21H22l-7-7v10z" clip-rule="evenodd"/><path fill="#324350" d="M15 24V14l7 7h-4.316z"/></g><defs><clipPath id="a"><path fill="#fff" d="M0 0h24v24H0z"/></clipPath></defs>
    </svg>;
}
