/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconRotate(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="M14.207 2.207A1 1 0 0 0 12.793.793l-2.5 2.5a1 1 0 0 0 0 1.414l2.5 2.5a1 1 0 1 0 1.414-1.414L13.414 5H16a5 5 0 0 1 5 5v2a1 1 0 1 0 2 0v-2a7 7 0 0 0-7-7h-2.586z"/><path fill="currentColor" d="M3 10a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>
    </svg>;
}
