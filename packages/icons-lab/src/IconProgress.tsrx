/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconProgress(props: { class?: string; style?: Record<string, any> }) {
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
        <circle cx="12" cy="12" r="8" stroke="#3BCE4A" stroke-width="6"/><path stroke="#3BCE4A" stroke-linecap="round" stroke-width="6" d="M12.138 4C16.48 4 20 7.582 20 12s-3.52 8-7.862 8C9.655 20 7.44 18.829 6 17"/>
    </svg>;
}
