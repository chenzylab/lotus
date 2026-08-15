/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconLeftCircleStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M2.5 12a9 9 0 1 1 18 0 9 9 0 0 1-18 0m9-11C5.425 1 .5 5.925.5 12s4.925 11 11 11 11-4.925 11-11-4.925-11-11-11m2.207 7.707a1 1 0 0 0-1.414-1.414l-3.89 3.889a1 1 0 0 0 0 1.414l3.89 3.89a1 1 0 0 0 1.414-1.415l-3.182-3.182z" clip-rule="evenodd"/>
    </svg>;
}
