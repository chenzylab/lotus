/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconElementStroked(props: { class?: string; style?: Record<string, any> }) {
    return <svg
        viewBox="0 0 25 24"
        fill="none"
        width="1em"
        height="1em"
        class={props.class}
        style={props.style}
        aria-hidden={true}
        xmlns="http://www.w3.org/2000/svg"
    >
        <path fill="currentColor" fill-rule="evenodd" d="M14.75 6.5a2.25 2.25 0 1 1-4.5 0 2.25 2.25 0 0 1 4.5 0M12.5 11a4.5 4.5 0 1 0 0-9 4.5 4.5 0 0 0 0 9M7 18.75a2.25 2.25 0 1 0 0-4.5 2.25 2.25 0 0 0 0 4.5m4.5-2.25a4.5 4.5 0 1 1-9 0 4.5 4.5 0 0 1 9 0m6.5 2.251a2.25 2.25 0 1 0 0-4.5 2.25 2.25 0 0 0 0 4.5m4.5-2.25a4.5 4.5 0 1 1-9 0 4.5 4.5 0 0 1 9 0" clip-rule="evenodd"/>
    </svg>;
}
