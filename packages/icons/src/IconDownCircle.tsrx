/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconDownCircle(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="M1 12C1 5.925 5.925 1 12 1s11 4.925 11 11-4.925 11-11 11S1 18.075 1 12m6.293-2.097c-.39.39-.39 1.025 0 1.415l3.889 3.889a1 1 0 0 0 1.415 0l3.888-3.889a1.001 1.001 0 0 0-1.414-1.415l-3.182 3.183-3.182-3.183a1 1 0 0 0-1.414 0"/>
    </svg>;
}
