/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconComponent(props: { class?: string; style?: Record<string, any> }) {
    return <svg
        viewBox="0 0 22 22"
        fill="none"
        width="1em"
        height="1em"
        class={props.class}
        style={props.style}
        aria-hidden={true}
        xmlns="http://www.w3.org/2000/svg"
    >
        <path fill="currentColor" d="m6 4 5-4 5 4-5 5.5zM18 6l4 5-4 5-5.5-5zM4 16l-4-5 4-5 5.5 5zM16 18l-5 4-5-4 5-5.5z"/>
    </svg>;
}
