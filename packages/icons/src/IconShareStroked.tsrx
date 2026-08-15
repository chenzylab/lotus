/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconShareStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M14 5.5a3.5 3.5 0 1 1 1.004 2.454l-5.13 3.109a3.5 3.5 0 0 1 .023 1.783l5.224 3.087a3.5 3.5 0 1 1-1.018 1.721l-5.224-3.087a3.5 3.5 0 1 1-.07-5.198l5.258-3.185A3.5 3.5 0 0 1 14 5.5M17.5 4a1.5 1.5 0 1 0 0 3 1.5 1.5 0 0 0 0-3m-11 6.5a1.5 1.5 0 1 0 0 3 1.5 1.5 0 0 0 0-3m9.5 8a1.5 1.5 0 1 1 3 0 1.5 1.5 0 0 1-3 0" clip-rule="evenodd"/>
    </svg>;
}
