/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconIdCard(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M4 4a3 3 0 0 0-3 3v11a3 3 0 0 0 3 3h16a3 3 0 0 0 3-3V7a3 3 0 0 0-3-3zm5.805 8.17c-.474 1.182-1.336 1.973-2.305 1.973s-1.83-.79-2.304-1.972c-.295-.117-.576-.473-.704-.938-.166-.606-.133-1.146.321-1.313C4.857 7.815 5.71 7 7.5 7s2.643.815 2.687 2.92c.453.168.486.708.32 1.313-.128.464-.408.82-.702.938m2.03 3.856c.415.426-.014.974-.617.974H3.782c-.603 0-1.033-.548-.617-.974.816-.836 2.451-1.407 4.335-1.407s3.518.57 4.335 1.407M14 10a1 1 0 0 1 1-1h5a1 1 0 1 1 0 2h-5a1 1 0 0 1-1-1m1 3a1 1 0 1 0 0 2h3a1 1 0 1 0 0-2z" clip-rule="evenodd"/>
    </svg>;
}
