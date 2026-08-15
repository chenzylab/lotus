/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconExternalOpen(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="M12 3.5A1.5 1.5 0 0 1 13.5 2h6A2.5 2.5 0 0 1 22 4.5v6a1.5 1.5 0 0 1-3 0V7l-7.94 7.94a1.5 1.5 0 0 1-2.12-2.122L16.756 5H13.5A1.5 1.5 0 0 1 12 3.5"/><path fill="currentColor" d="M5 8.5v10a.5.5 0 0 0 .5.5h10a.5.5 0 0 0 .5-.5v-3a1.5 1.5 0 0 1 3 0v3a3.5 3.5 0 0 1-3.5 3.5h-10A3.5 3.5 0 0 1 2 18.5v-10A3.5 3.5 0 0 1 5.5 5h3a1.5 1.5 0 1 1 0 3h-3a.5.5 0 0 0-.5.5"/>
    </svg>;
}
