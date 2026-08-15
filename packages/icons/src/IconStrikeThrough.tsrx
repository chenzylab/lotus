/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconStrikeThrough(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M11.5 4.5c-1.787 0-3 1.44-3 2.5 0 1.069.76 2.6 3.716 3.5h-5.47C5.931 9.475 5.5 8.285 5.5 7c0-2.94 2.787-5.5 6-5.5 2.972 0 5.417 1.222 7.2 3.6a1.5 1.5 0 0 1-2.4 1.8c-1.217-1.622-2.772-2.4-4.8-2.4M15.718 15.5h3.526c.164.466.256.967.256 1.5 0 1.872-1.035 3.305-2.455 4.205C15.658 22.083 13.86 22.5 12 22.5c-3.923 0-6.77-2.395-7.455-5.136A1.5 1.5 0 0 1 5.97 15.5h.06a1.5 1.5 0 0 1 1.424 1.136C7.77 17.895 9.295 19.5 12 19.5c1.455 0 2.655-.333 3.44-.83.752-.476 1.06-1.042 1.06-1.67 0-.433-.196-.941-.782-1.5M2.5 10.5h19a1.5 1.5 0 0 1 0 3h-19a1.5 1.5 0 0 1 0-3" clip-rule="evenodd"/>
    </svg>;
}
