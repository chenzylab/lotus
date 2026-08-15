/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconAlignCenterVertical(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M13.5 5.915V3a1.5 1.5 0 0 0-3 0v2.915l-1.256-.717a1.5 1.5 0 0 0-1.488 2.604l3.5 2a1.5 1.5 0 0 0 1.488 0l3.5-2a1.5 1.5 0 1 0-1.488-2.604zm-9 7.585a1.5 1.5 0 0 1 0-3h15a1.5 1.5 0 0 1 0 3zm9 4.585 1.256.717a1.5 1.5 0 1 0 1.488-2.604l-3.5-2a1.5 1.5 0 0 0-1.488 0l-3.5 2a1.5 1.5 0 0 0 1.488 2.604l1.256-.717V21a1.5 1.5 0 0 0 3 0z" clip-rule="evenodd"/>
    </svg>;
}
