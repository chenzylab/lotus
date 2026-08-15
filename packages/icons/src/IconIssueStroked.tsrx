/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconIssueStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <g fill="currentColor" fill-rule="evenodd" clip-path="url(#a)" clip-rule="evenodd"><path d="M4.133 4.133A11.1 11.1 0 0 1 12 .875c3.072 0 5.855 1.246 7.866 3.258A11.1 11.1 0 0 1 23.126 12c0 3.072-1.247 5.855-3.259 7.866A11.1 11.1 0 0 1 12 23.126a11.1 11.1 0 0 1-7.867-3.258A11.1 11.1 0 0 1 .875 12c0-3.072 1.246-5.855 3.258-7.867m1.591 1.591A8.84 8.84 0 0 1 12 3.125c2.451 0 4.668.992 6.276 2.6A8.84 8.84 0 0 1 20.875 12a8.84 8.84 0 0 1-2.6 6.276A8.84 8.84 0 0 1 12 20.875a8.84 8.84 0 0 1-6.276-2.6A8.84 8.84 0 0 1 3.125 12c0-2.451.992-4.668 2.6-6.276"/><path d="M12 18.5a1.25 1.25 0 1 0 0-2.5 1.25 1.25 0 0 0 0 2.5M12 4.875c.621 0 1.125.504 1.125 1.125v8a1.125 1.125 0 0 1-2.25 0V6c0-.621.504-1.125 1.125-1.125"/></g><defs><clipPath id="a"><path fill="currentColor" d="M0 0h24v24H0z"/></clipPath></defs>
    </svg>;
}
