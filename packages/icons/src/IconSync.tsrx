/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconSync(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M12 4.5a7.5 7.5 0 0 0-7.083 5.028 1.5 1.5 0 0 1-2.833-.988C3.514 4.443 7.411 1.5 12 1.5c3.577 0 6.733 1.788 8.629 4.516l.434-1.447a1.5 1.5 0 1 1 2.873.862l-1.5 5a1.5 1.5 0 0 1-1.73 1.04l-5-1a1.5 1.5 0 1 1 .588-2.942l2.007.401A7.5 7.5 0 0 0 12 4.5M5.699 16.069l2.007.401a1.5 1.5 0 1 0 .588-2.941l-5-1a1.5 1.5 0 0 0-1.73 1.04l-1.5 5a1.5 1.5 0 0 0 2.873.861l.434-1.447A10.49 10.49 0 0 0 12 22.499c4.574 0 8.461-2.924 9.902-7a1.5 1.5 0 1 0-2.829-1A7.504 7.504 0 0 1 5.7 16.07" clip-rule="evenodd"/>
    </svg>;
}
