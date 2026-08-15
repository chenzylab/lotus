/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconLineHeight(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="m19.128 3.177-3.377 3.752a.5.5 0 0 0 .372.835H18v8.649h-1.877a.5.5 0 0 0-.372.834L19.128 21a.5.5 0 0 0 .744 0l3.377-3.753a.5.5 0 0 0-.372-.834H21v-8.65h1.877a.5.5 0 0 0 .372-.834l-3.377-3.752a.5.5 0 0 0-.744 0M2.286 4C1.576 4 1 4.672 1 5.5S1.576 7 2.286 7h11.428C14.424 7 15 6.328 15 5.5S14.424 4 13.714 4zM1 12c0-.828.576-1.5 1.286-1.5h11.428c.71 0 1.286.672 1.286 1.5s-.576 1.5-1.286 1.5H2.286C1.576 13.5 1 12.828 1 12m0 6.5c0-.828.576-1.5 1.286-1.5h11.428c.71 0 1.286.672 1.286 1.5s-.576 1.5-1.286 1.5H2.286C1.576 20 1 19.328 1 18.5" clip-rule="evenodd" opacity=".99"/>
    </svg>;
}
