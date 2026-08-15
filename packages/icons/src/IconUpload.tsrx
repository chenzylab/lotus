/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconUpload(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M17.84 8.058a6.5 6.5 0 1 0-12.663 2.953A4.5 4.5 0 0 0 5.5 20H17a6 6 0 0 0 .84-11.942m-5.52.209a.5.5 0 0 0-.64 0l-5.15 4.29a.25.25 0 0 0 .16.443H10v4.5a.5.5 0 0 0 .5.5h3a.5.5 0 0 0 .5-.5V13h3.31a.25.25 0 0 0 .16-.442z" clip-rule="evenodd"/>
    </svg>;
}
