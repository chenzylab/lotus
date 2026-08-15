/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconReply(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="m2.275 11.31 8.073-8.499c.619-.652 1.713-.211 1.713.69v4.002C19.022 7.503 23 12 23 17.996c0 .5-.241 2.18-.556 2.316-.137.06-.288-.014-.438-.317-2.224-4.47-4.475-4.497-9.945-4.497v5c0 .902-1.094 1.343-1.713.69L2.274 12.69a1.003 1.003 0 0 1 0-1.38"/>
    </svg>;
}
