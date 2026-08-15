/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconMute(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M12 3a1 1 0 0 0-1.625-.78L4.65 7H2a1 1 0 0 0-1 1v8a1 1 0 0 0 1 1h2.65l5.725 4.78A1 1 0 0 0 12 21zm2.06 4.94a1.5 1.5 0 0 1 2.122 0L18 9.756l1.818-1.818a1.5 1.5 0 1 1 2.121 2.122l-1.818 1.818 1.94 1.939a1.5 1.5 0 0 1-2.122 2.121L18 14l-1.94 1.94a1.5 1.5 0 0 1-2.12-2.122l1.939-1.94-1.818-1.817a1.5 1.5 0 0 1 0-2.122" clip-rule="evenodd"/>
    </svg>;
}
