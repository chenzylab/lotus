/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconSort(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="m6.451 8.342 4.797-6.482a1 1 0 0 1 1.505 0l4.796 6.482c.566.646.107 1.658-.753 1.658H7.204c-.86 0-1.318-1.012-.753-1.658M17.549 15.659l-4.796 6.48a1 1 0 0 1-1.505 0L6.45 15.66C5.886 15.012 6.345 14 7.204 14h9.592c.86 0 1.319 1.012.753 1.659"/>
    </svg>;
}
