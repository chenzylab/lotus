/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconTimePicker(props: { class?: string; style?: Record<string, any> }) {
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
        <circle cx="12" cy="12" r="10.25" fill="#fff" stroke="#AAB2BF" stroke-width="1.5"/><path stroke="#6A6F7F" stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M14.5 6.5 12 12l5 5.5"/><circle cx="12" cy="12" r="2" fill="#324350"/><path stroke="#FBCD2C" stroke-linecap="round" d="M13 11.625 12 12l-7 3"/><circle cx="12" cy="12" r="1" fill="#FBCD2C"/>
    </svg>;
}
