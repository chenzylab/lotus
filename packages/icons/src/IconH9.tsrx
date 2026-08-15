/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconH9(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M3.5 2.5A1.5 1.5 0 0 1 5 4v6.5h6V4a1.5 1.5 0 0 1 3 0v16a1.5 1.5 0 0 1-3 0v-6.5H5V20a1.5 1.5 0 0 1-3 0V4a1.5 1.5 0 0 1 1.5-1.5" clip-rule="evenodd"/><path fill="currentColor" d="M19.705 14.745c0 .643-.444 1.121-1.032 1.121s-1.019-.478-1.019-1.128c0-.642.424-1.107 1.012-1.107.595 0 1.04.478 1.04 1.114m-4.43 4.655c0 .52.349.971.916 1.292s1.347.513 2.215.513c2.694 0 4.28-1.784 4.28-4.874 0-2.987-1.532-4.82-4.027-4.82-2.187 0-3.664 1.347-3.664 3.344 0 1.763 1.176 3 2.85 3 .958 0 1.799-.505 2.134-1.285h.061c0 1.566-.581 2.489-1.627 2.489-.56 0-.882-.185-1.271-.431-.315-.198-.54-.26-.828-.26-.574 0-1.039.417-1.039 1.032"/>
    </svg>;
}
