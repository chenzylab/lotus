/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconTransfer(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="#AAB2BF" d="m7.07 20.351-5.483-4.382a.6.6 0 0 1 0-.938L7.07 10.65a.5.5 0 0 1 .812.39V13.3h5.668a.45.45 0 0 1 .45.45v3.5a.45.45 0 0 1-.45.45H7.882v2.26a.5.5 0 0 1-.812.391"/><path fill="#fff" d="m13.807 5.628 7.584 5.898a.6.6 0 0 1 0 .948l-7.584 5.898a.5.5 0 0 1-.807-.394V14.8H7.5a.5.5 0 0 1-.5-.5V9.7a.5.5 0 0 1 .5-.5H13V6.022a.5.5 0 0 1 .807-.394"/><path fill="#4CC3FA" d="m14.807 4.628 7.584 5.898a.6.6 0 0 1 0 .948l-7.584 5.898a.5.5 0 0 1-.807-.394V13.8H8.5a.5.5 0 0 1-.5-.5V8.7a.5.5 0 0 1 .5-.5H14V5.022a.5.5 0 0 1 .807-.394"/>
    </svg>;
}
