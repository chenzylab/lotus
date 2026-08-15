/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconArrowUpLeft(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M3.5 18A1.5 1.5 0 0 1 2 16.5v-13A1.5 1.5 0 0 1 3.5 2h13a1.5 1.5 0 0 1 0 3H7.121l13.44 13.44a1.5 1.5 0 0 1-2.122 2.12L5 7.122V16.5A1.5 1.5 0 0 1 3.5 18" clip-rule="evenodd"/>
    </svg>;
}
