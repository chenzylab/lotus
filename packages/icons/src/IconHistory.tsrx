/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconHistory(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M12 4.5a7.5 7.5 0 1 1-7.073 10 1.5 1.5 0 0 0-2.829 1c1.44 4.076 5.328 7 9.902 7 5.799 0 10.5-4.701 10.5-10.5S17.799 1.5 12 1.5a10.49 10.49 0 0 0-8.629 4.516L2.937 4.57a1.5 1.5 0 1 0-2.873.862l1.5 5a1.5 1.5 0 0 0 1.73 1.04l5-1a1.5 1.5 0 0 0-.588-2.942L5.7 7.931A7.5 7.5 0 0 1 12 4.5m1.5 3a1.5 1.5 0 0 0-3 0V12c0 .398.158.78.44 1.06l3 3a1.5 1.5 0 0 0 2.12-2.12l-2.56-2.561z" clip-rule="evenodd"/>
    </svg>;
}
