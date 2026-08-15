/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconSimilarity(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M8 4c1.457 0 2.823.39 4 1.07a8 8 0 1 1 0 13.86A8 8 0 1 1 8 4m8 14a6 6 0 1 0-3.969-10.5h2.584c.319.467.589.97.803 1.5h-4.615q-.275.475-.462 1h5.407q.188.727.237 1.5H10.02a6 6 0 0 0 0 1h5.964a8 8 0 0 1-.237 1.5h-5.407q.187.525.462 1h4.615a8 8 0 0 1-.803 1.5h-2.584A5.98 5.98 0 0 0 16 18" clip-rule="evenodd"/>
    </svg>;
}
