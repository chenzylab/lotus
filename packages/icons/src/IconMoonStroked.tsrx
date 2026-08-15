/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconMoonStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="M8.272 8.363a7.34 7.34 0 0 1 2.184-5.23 9 9 0 1 0 10.41 10.41 7.34 7.34 0 0 1-5.23 2.185 7.365 7.365 0 0 1-7.364-7.365m2 0a5.365 5.365 0 0 0 9.863 2.923l.076-.107c.397-.513 1.024-.671 1.52-.6.553.08 1.269.524 1.269 1.421 0 6.075-4.925 11-11 11S1 18.075 1 12 5.925 1 12 1c.897 0 1.342.716 1.42 1.269.077.53-.108 1.207-.706 1.596a5.36 5.36 0 0 0-2.441 4.498"/>
    </svg>;
}
