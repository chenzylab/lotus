/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconUnderline(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="M7 2a1.5 1.5 0 0 0-1.5 1.5V11a6.5 6.5 0 1 0 13 0V3.5a1.5 1.5 0 0 0-3 0V11a3.5 3.5 0 1 1-7 0V3.5A1.5 1.5 0 0 0 7 2M5.5 19a1.5 1.5 0 0 0 0 3h13a1.5 1.5 0 0 0 0-3z"/>
    </svg>;
}
