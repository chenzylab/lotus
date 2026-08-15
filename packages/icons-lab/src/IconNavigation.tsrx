/** 模块级自增计数器，为每次渲染生成唯一的本地 id 后缀（见 extractLocalIds/makeIdsUnique）。 */
let uidCounter = 0;

/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconNavigation(props: { class?: string; style?: Record<string, any> }) {
    const uid = `lotus-iconnavigation-${uidCounter++}`;
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
        <g clip-path={`url(#${uid}-a)`}><circle cx="12" cy="12" r="11" fill="#DDE3E8" transform="rotate(-45 12 12)"/><path fill="#324350" d="m4.954 12.237 11.864-5.314-4.58 12.166-1.728-5.46z"/></g><defs><clipPath id={`${uid}-a`}><path fill="#fff" d="M0 0h24v24H0z"/></clipPath></defs>
    </svg>;
}
