/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconPercentage(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M21.56 2.44a1.5 1.5 0 0 1 0 2.12l-17 17a1.5 1.5 0 0 1-2.12-2.12l17-17a1.5 1.5 0 0 1 2.12 0M6.5 5a1.5 1.5 0 1 0 0 3 1.5 1.5 0 0 0 0-3M2 6.5a4.5 4.5 0 1 1 9 0 4.5 4.5 0 0 1-9 0m14 11a1.5 1.5 0 1 1 3 0 1.5 1.5 0 0 1-3 0m1.5-4.5a4.5 4.5 0 1 0 0 9 4.5 4.5 0 0 0 0-9" clip-rule="evenodd"/>
    </svg>;
}
