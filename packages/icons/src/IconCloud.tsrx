/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconCloud(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M11.5 3a6.5 6.5 0 0 1 6.34 5.058A6.001 6.001 0 0 1 17 20H5.5a4.5 4.5 0 0 1-.323-8.989A6.5 6.5 0 0 1 11.5 3" clip-rule="evenodd"/>
    </svg>;
}
