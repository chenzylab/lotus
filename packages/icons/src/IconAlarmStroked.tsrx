/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconAlarmStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <g fill="currentColor" clip-path="url(#a)"><path d="M12 7.637a.91.91 0 0 1 .91.909v5.077l3.966 3.968a.909.909 0 1 1-1.285 1.285l-4.179-4.178-.03-.033A.9.9 0 0 1 11.09 14V8.546a.91.91 0 0 1 .909-.91"/><path fill-rule="evenodd" d="M12 4c5.523 0 10 4.477 10 10s-4.477 10-10 10S2 19.523 2 14 6.477 4 12 4m0 2a8 8 0 1 0 0 16 8 8 0 0 0 0-16" clip-rule="evenodd"/><path d="M3.535 1.414a2 2 0 1 1 2.829 2.829L4.243 6.364a2 2 0 1 1-2.829-2.828zM20.464 1.414a2 2 0 1 0-2.828 2.829l2.121 2.121a2 2 0 1 0 2.829-2.828z"/></g><defs><clipPath id="a"><path fill="currentColor" d="M0 0h24v24H0z"/></clipPath></defs>
    </svg>;
}
