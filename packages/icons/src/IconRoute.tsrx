/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconRoute(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="m10.136 1.879-8.257 8.257a3 3 0 0 0 0 4.243l8.257 8.257a3 3 0 0 0 4.243 0l8.257-8.257a3 3 0 0 0 0-4.243l-8.257-8.257a3 3 0 0 0-4.243 0m4.828 5.671a1 1 0 1 0-1.414 1.414l1.293 1.293H9.257a1 1 0 0 0-1 1v5a1 1 0 0 0 2 0v-4h4.586L13.55 13.55a1 1 0 1 0 1.414 1.414l3-3a1 1 0 0 0 0-1.414z" clip-rule="evenodd"/>
    </svg>;
}
