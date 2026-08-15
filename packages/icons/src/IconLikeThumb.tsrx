/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconLikeThumb(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="m8.059 9.39 3.713-6.963c.127-.238.42-.33.64-.175.582.41 1.421 1.2 1.421 2.123 0 .5-.132 1.397-.27 2.338-.153 1.035-.313 2.122-.313 2.787h7.583C21.278 9.5 22 9.952 22 11c0 .904-.992 5.087-1.692 8.042L20 20.345c0 .218-.267.655-1.333.655H8.498A.5.5 0 0 1 8 20.5V9.625a.5.5 0 0 1 .059-.235M3.5 9.5a.5.5 0 0 0-.5.5v10.5a.5.5 0 0 0 .5.5h2a.5.5 0 0 0 .5-.5V10a.5.5 0 0 0-.5-.5z" clip-rule="evenodd"/>
    </svg>;
}
