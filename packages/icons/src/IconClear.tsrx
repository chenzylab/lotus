/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconClear(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M12 23c6.075 0 11-4.925 11-11S18.075 1 12 1 1 5.925 1 12s4.925 11 11 11m5.035-6.137a1.5 1.5 0 0 1-2.12.037l-2.878-2.779-2.779 2.877A1.5 1.5 0 0 1 7.1 14.914l2.779-2.877L7 9.258A1.5 1.5 0 1 1 9.085 7.1l2.878 2.779 2.778-2.877A1.5 1.5 0 0 1 16.9 9.086l-2.78 2.877 2.878 2.779a1.5 1.5 0 0 1 .037 2.12" clip-rule="evenodd"/>
    </svg>;
}
