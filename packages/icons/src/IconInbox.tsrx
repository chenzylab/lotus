/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconInbox(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M.215 12.464A3 3 0 0 0 0 13.578V19a3 3 0 0 0 3 3h18a3 3 0 0 0 3-3v-5.422c0-.382-.073-.76-.215-1.114l-3.282-8.207A2 2 0 0 0 18.646 3H5.354a2 2 0 0 0-1.857 1.257zM5.5 6h13l2.5 7h-5a1 1 0 0 0-1 1 3 3 0 1 1-6 0 1 1 0 0 0-1-1H3z" clip-rule="evenodd"/>
    </svg>;
}
