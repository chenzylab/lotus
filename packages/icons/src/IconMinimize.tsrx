/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconMinimize(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M8.5 2A1.5 1.5 0 0 1 10 3.5v3A3.5 3.5 0 0 1 6.5 10h-3a1.5 1.5 0 1 1 0-3h3a.5.5 0 0 0 .5-.5v-3A1.5 1.5 0 0 1 8.5 2M16 2a1.5 1.5 0 0 1 1.5 1.5v3a.5.5 0 0 0 .5.5h3a1.5 1.5 0 0 1 0 3h-3a3.5 3.5 0 0 1-3.5-3.5v-3A1.5 1.5 0 0 1 16 2M2 15.5A1.5 1.5 0 0 1 3.5 14h3a3.5 3.5 0 0 1 3.5 3.5v3a1.5 1.5 0 0 1-3 0v-3a.5.5 0 0 0-.5-.5h-3A1.5 1.5 0 0 1 2 15.5m12 2a3.5 3.5 0 0 1 3.5-3.5h3a1.5 1.5 0 0 1 0 3h-3a.5.5 0 0 0-.5.5v3a1.5 1.5 0 0 1-3 0z" clip-rule="evenodd"/>
    </svg>;
}
