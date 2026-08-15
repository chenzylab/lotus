/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconClose(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="M17.657 19.778a1.5 1.5 0 0 0 2.121-2.121L14.121 12l5.657-5.657a1.5 1.5 0 0 0-2.121-2.121L12 9.879 6.343 4.222a1.5 1.5 0 1 0-2.121 2.121L9.879 12l-5.657 5.657a1.5 1.5 0 0 0 2.121 2.121L12 14.121z"/>
    </svg>;
}
