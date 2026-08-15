/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconKey(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M23 8.5a7.5 7.5 0 0 1-11.405 6.405L11 15.5V19H7v4H2v-4l6.912-6.912A7.5 7.5 0 1 1 23 8.5m-4-1a2.5 2.5 0 1 0-5 0 2.5 2.5 0 0 0 5 0" clip-rule="evenodd"/>
    </svg>;
}
