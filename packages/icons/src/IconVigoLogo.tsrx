/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconVigoLogo(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M10.763 1c-.128 2.39-1.685 4.407-3.84 5.225A5.9 5.9 0 0 1 6.7 4.408C4.169 6.745 2.5 10.51 2.5 13.74c0 5.114 4.186 9.26 9.35 9.26s9.35-4.146 9.35-9.26c0-3.097-1.535-6.687-3.892-9.038a5.93 5.93 0 0 1-2.44 4.005c.22-.617.338-1.28.338-1.971 0-2.748-1.884-5.06-4.443-5.736M9.278 9.45l-.092-.034zm-.305 1.647v6.236c0 .643.705 1.042 1.264.716l5.357-3.118a.827.827 0 0 0 0-1.433l-5.357-3.118c-.559-.325-1.264.074-1.264.717" clip-rule="evenodd"/>
    </svg>;
}
