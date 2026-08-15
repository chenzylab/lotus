/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconRefresh(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M4.5 12A7.5 7.5 0 0 1 18.3 7.93l-2.007-.401a1.5 1.5 0 0 0-.588 2.942l5 1a1.5 1.5 0 0 0 1.73-1.04l1.5-5a1.5 1.5 0 1 0-2.873-.862l-.434 1.447a10.49 10.49 0 0 0-8.63-4.516C6.202 1.5 1.5 6.2 1.5 12S6.2 22.5 12 22.5c4.574 0 8.461-2.924 9.902-7a1.5 1.5 0 1 0-2.829-1A7.5 7.5 0 0 1 4.5 12" clip-rule="evenodd"/>
    </svg>;
}
