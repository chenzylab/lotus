/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconPriceTag(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M21 2h-7.586a1 1 0 0 0-.707.293L1.414 13.586a2 2 0 0 0 0 2.828l6.172 6.172a2 2 0 0 0 2.828 0l11.293-11.293a1 1 0 0 0 .293-.707V3a1 1 0 0 0-1-1m-5.5 9a2.5 2.5 0 1 0 0-5 2.5 2.5 0 0 0 0 5" clip-rule="evenodd"/>
    </svg>;
}
