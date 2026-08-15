/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconColorPalette(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M2 4a2 2 0 0 1 2-2h5a2 2 0 0 1 2 2v16a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2zm6 13.5a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0m11.586-8.914-3.172-3.172a2 2 0 0 0-2.828 0L13 6v12l6.586-6.586a2 2 0 0 0 0-2.828M22 16a2 2 0 0 0-2-2l-8 8h8a2 2 0 0 0 2-2z" clip-rule="evenodd"/>
    </svg>;
}
