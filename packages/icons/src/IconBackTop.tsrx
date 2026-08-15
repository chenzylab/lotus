/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconBackTop(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M11.94 22.94a1.5 1.5 0 0 1-1.5-1.5V10.06l-4.38 4.38a1.5 1.5 0 1 1-2.12-2.122l6.939-6.94a1.5 1.5 0 0 1 2.121 0l7.06 7.061a1.5 1.5 0 0 1-2.12 2.122l-4.5-4.5v11.378a1.5 1.5 0 0 1-1.5 1.5M18.44.94a1.5 1.5 0 1 1 0 3h-13a1.5 1.5 0 1 1 0-3z" clip-rule="evenodd"/>
    </svg>;
}
