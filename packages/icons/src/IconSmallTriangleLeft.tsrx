/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconSmallTriangleLeft(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="M16.318 6.956v10.132a.5.5 0 0 1-.778.416l-7.598-5.066a.5.5 0 0 1 0-.832L15.54 6.54a.5.5 0 0 1 .778.416"/>
    </svg>;
}
