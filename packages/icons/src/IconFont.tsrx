/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconFont(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M13.372 2.895a1.5 1.5 0 0 0-2.745 0l-7.5 17a1.5 1.5 0 0 0 2.745 1.21L7.684 17h8.632l1.812 4.105a1.5 1.5 0 1 0 2.744-1.21zM14.992 14 12 7.216 9.007 14z" clip-rule="evenodd"/>
    </svg>;
}
