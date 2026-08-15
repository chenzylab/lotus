/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconSortStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M6.614 14.036A1 1 0 0 1 7.5 13.5h9a1 1 0 0 1 .822 1.57l-4.5 6.5a1 1 0 0 1-1.644 0l-4.5-6.5a1 1 0 0 1-.064-1.034M9.41 15.5 12 19.243l2.591-3.743zM12 2a1 1 0 0 1 .822.43l4.5 6.5a1 1 0 0 1-.822 1.57h-9a1 1 0 0 1-.822-1.57l4.5-6.5A1 1 0 0 1 12 2M9.409 8.5h5.182L12 4.757z" clip-rule="evenodd"/>
    </svg>;
}
