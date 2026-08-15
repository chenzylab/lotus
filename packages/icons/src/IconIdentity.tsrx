/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconIdentity(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M4 4a1 1 0 0 1 1-1h1.375a1 1 0 0 1 1 1v16a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1zm5.625 0a1 1 0 0 1 1-1h4.625a5.625 5.625 0 0 1 5.625 5.625v6.75A5.625 5.625 0 0 1 15.25 21h-4.625a1 1 0 0 1-1-1zM17.5 15.375v-6.75a2.25 2.25 0 0 0-2.25-2.25H13v11.25h2.25a2.25 2.25 0 0 0 2.25-2.25" clip-rule="evenodd"/>
    </svg>;
}
