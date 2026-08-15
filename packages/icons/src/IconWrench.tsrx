/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconWrench(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M10.53 14.53a7 7 0 0 1-9.031-9.126c.124-.315.527-.378.766-.14l3.028 3.029a1 1 0 0 0 1.414 0l1.586-1.586a1 1 0 0 0 0-1.414L5.265 2.265c-.24-.24-.176-.642.138-.767a7 7 0 0 1 9.126 9.031l7.557 7.557a2 2 0 0 1 0 2.828l-1.172 1.172a2 2 0 0 1-2.828 0z" clip-rule="evenodd"/>
    </svg>;
}
