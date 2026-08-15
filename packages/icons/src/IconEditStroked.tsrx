/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconEditStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M18.58 2.587a2.003 2.003 0 0 0-2.832 0L13.625 4.71l-.001.001-.708.708-9.794 9.793c-.148.149-.246.34-.28.547l-.829 5.078a1.002 1.002 0 0 0 1.15 1.15l5.078-.83c.207-.033.398-.131.547-.28l9.793-9.793.708-.708 2.124-2.124a2.003 2.003 0 0 0 0-2.833zm0 5.665 1.417-1.416-2.832-2.833-1.417 1.416zm-1.415 1.416-2.833-2.832L4.767 16.4l-.553 3.385 3.386-.553z" clip-rule="evenodd"/>
    </svg>;
}
