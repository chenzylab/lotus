/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconBox(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="m2 6 8.554-4.705a3 3 0 0 1 2.892 0L22 6l-10 5zM11 12.5l-10-5v8.646a3 3 0 0 0 1.658 2.683L11 23zM23 7.5l-10 5V23l8.342-4.17A3 3 0 0 0 23 16.145z"/>
    </svg>;
}
