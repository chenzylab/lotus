/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconPlusCircle(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M12 23c6.075 0 11-4.925 11-11S18.075 1 12 1 1 5.925 1 12s4.925 11 11 11m6.999-11.122a1.5 1.5 0 0 1-1.474 1.526l-4 .07.07 3.999a1.5 1.5 0 0 1-2.999.052l-.07-3.999-4 .07a1.5 1.5 0 0 1-.052-3l4-.07-.07-3.999a1.5 1.5 0 1 1 3-.052l.07 4 3.999-.07a1.5 1.5 0 0 1 1.526 1.473" clip-rule="evenodd"/>
    </svg>;
}
