/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconAlignCenter(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M3.5 3a1.5 1.5 0 1 0 0 3h17a1.5 1.5 0 0 0 0-3zm3 5a1.5 1.5 0 1 0 0 3h11a1.5 1.5 0 0 0 0-3zM2 14.5A1.5 1.5 0 0 1 3.5 13h17a1.5 1.5 0 0 1 0 3h-17A1.5 1.5 0 0 1 2 14.5M6.5 18a1.5 1.5 0 0 0 0 3h11a1.5 1.5 0 0 0 0-3z" clip-rule="evenodd"/>
    </svg>;
}
