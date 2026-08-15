/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconFilledArrowDown(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="m22.146 12.06-9.792 9.794a.5.5 0 0 1-.708 0L1.854 12.06a.5.5 0 0 1 .353-.854H8v-9a1 1 0 0 1 1-1h6a1 1 0 0 1 1 1v9h5.793a.5.5 0 0 1 .353.854"/>
    </svg>;
}
