/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconActivity(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M12 1a1.5 1.5 0 0 0 0 3 8 8 0 1 1 0 16 7.96 7.96 0 0 1-4.752-1.564 1.5 1.5 0 1 0-1.785 2.412A10.96 10.96 0 0 0 12 23c6.075 0 11-4.925 11-11S18.075 1 12 1M7.5 5.2a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3M5.5 7a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0m-3 6a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3M5 16.5a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0m8.5-9a1.5 1.5 0 0 0-3 0V12c0 .398.158.78.44 1.06l3 3a1.5 1.5 0 0 0 2.12-2.12l-2.56-2.561z" clip-rule="evenodd"/>
    </svg>;
}
