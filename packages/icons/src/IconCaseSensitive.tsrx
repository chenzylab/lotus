/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconCaseSensitive(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M8.918 4.011a1.5 1.5 0 0 0-2.836 0l-5 14.5a1.5 1.5 0 0 0 2.836.978l1.03-2.989h5.103l1.03 2.989a1.5 1.5 0 1 0 2.837-.978zm.099 9.489H5.983L7.5 9.101zm6.983 1c0-2.03 1.224-3 2-3s2 .97 2 3-1.224 3-2 3-2-.97-2-3m2-6c.854 0 1.617.233 2.275.633A1.5 1.5 0 0 1 23 10v9a1.5 1.5 0 0 1-2.724.867c-.658.4-1.421.633-2.275.633-3.09 0-5-3.059-5-6s1.91-6 5-6" clip-rule="evenodd"/>
    </svg>;
}
