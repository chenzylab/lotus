/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconLeftCircle(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="M12 1c6.075 0 11 4.925 11 11s-4.925 11-11 11S1 18.075 1 12 5.925 1 12 1m2.097 6.293a1 1 0 0 0-1.415 0l-3.889 3.889c-.39.39-.39 1.024 0 1.415l3.889 3.888a1.001 1.001 0 0 0 1.415-1.414l-3.183-3.182 3.183-3.182a1 1 0 0 0 0-1.414"/>
    </svg>;
}
