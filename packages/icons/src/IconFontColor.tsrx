/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconFontColor(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M13.352 1.885a1.5 1.5 0 0 0-2.704 0l-6 12.966a1.5 1.5 0 1 0 2.704 1.298l1.272-2.65h6.752l1.272 2.65a1.5 1.5 0 1 0 2.704-1.298zM12 6l1.936 4.5h-3.872zM3 18a1 1 0 0 0-1 1v2a1 1 0 0 0 1 1h18a1 1 0 0 0 1-1v-2a1 1 0 0 0-1-1z" clip-rule="evenodd"/>
    </svg>;
}
