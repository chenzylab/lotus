/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconUndo(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M9.56 2.44a1.5 1.5 0 0 1 0 2.12L7.122 7h7.629C18.835 7 22 10.58 22 14.5S18.835 22 14.75 22H11.5a1.5 1.5 0 0 1 0-3h3.25c2.266 0 4.25-2.07 4.25-4.5S17.016 10 14.75 10H7.121l2.44 2.44a1.5 1.5 0 0 1-2.122 2.12l-5-5a1.5 1.5 0 0 1 0-2.12l5-5a1.5 1.5 0 0 1 2.122 0" clip-rule="evenodd"/>
    </svg>;
}
