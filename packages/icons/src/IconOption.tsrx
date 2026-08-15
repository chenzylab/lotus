/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconOption(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M3.5 3.5a1.5 1.5 0 1 0 0 3h3.63l7.568 13.244A1.5 1.5 0 0 0 16 20.5h4.5a1.5 1.5 0 0 0 0-3h-3.63L9.303 4.256A1.5 1.5 0 0 0 8 3.5zm11 0a1.5 1.5 0 0 0 0 3h6a1.5 1.5 0 0 0 0-3z" clip-rule="evenodd"/>
    </svg>;
}
