/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconSpin(props: { class?: string; style?: Record<string, any> }) {
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
        <g clip-path="url(#a)"><path fill="currentColor" fill-rule="evenodd" d="M14.2 3.79a8.5 8.5 0 0 0-9.208 13.02 1.5 1.5 0 1 1-2.475 1.697A11.48 11.48 0 0 1 .892 9.023C2.536 2.889 8.842-.752 14.976.892c6.135 1.644 9.776 7.95 8.132 14.085a1.5 1.5 0 0 1-2.898-.777A8.5 8.5 0 0 0 14.2 3.79" clip-rule="evenodd"/></g><defs><clipPath id="a"><path fill="currentColor" d="M0 0h24v24H0z"/></clipPath></defs>
    </svg>;
}
