/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconWebcomponents(props: { class?: string; style?: Record<string, any> }) {
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
        <rect width="20" height="20" x="2" y="2" fill="#41B3FF" rx="5"/><rect width="10" height="3" x="7" y="5.5" fill="#E9E7E7" rx="1.5"/><rect width="10" height="3" x="7" y="10.5" fill="#483D3D" rx="1.5"/><rect width="10" height="3" x="7" y="15.5" fill="#E9E7E7" rx="1.5"/>
    </svg>;
}
