/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconRating(props: { class?: string; style?: Record<string, any> }) {
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
        <g clip-path="url(#a)"><path fill="#FBCD2C" d="M7.926 5.503a.833.833 0 0 1 1.366-.286l3.617 3.627 5.131.265c.606.031.976.68.696 1.217l-2.363 4.529 1.302 4.875a.833.833 0 0 1-.967 1.032l-5.09-1.01-4.259 2.965a.833.833 0 0 1-1.3-.559L5.3 17.17l-3.978-3.203a.833.833 0 0 1 .15-1.394l4.595-2.298z"/><path fill="#DDE3E8" d="M19.937 1.136a.36.36 0 0 1 .572.193l.553 2.141 1.853 1.221a.36.36 0 0 1-.008.606l-1.87 1.17-.581 2.1a.36.36 0 0 1-.586.172L18.195 7.25l-2.234.172a.36.36 0 0 1-.362-.492l.808-2.024-.781-2.063a.36.36 0 0 1 .36-.486l2.215.15z"/></g><defs><clipPath id="a"><path fill="#fff" d="M0 0h24v24H0z"/></clipPath></defs>
    </svg>;
}
