/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconPuzzle(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M14.663 5a3.5 3.5 0 1 0-6.326 0H5a2 2 0 0 0-2 2v3.337a3.5 3.5 0 1 1 0 6.326V21a2 2 0 0 0 2 2h13a2 2 0 0 0 2-2v-4.035q.245.035.5.035a3.5 3.5 0 1 0-.5-6.965V7a2 2 0 0 0-2-2z" clip-rule="evenodd"/>
    </svg>;
}
