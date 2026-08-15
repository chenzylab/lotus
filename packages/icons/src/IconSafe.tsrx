/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconSafe(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="m2.72 3.722 8.72-2.637a2 2 0 0 1 1.146 0l8.708 2.634a.98.98 0 0 1 .702.931c.026 2.646-.033 11.79-2.005 14.361-1.97 2.567-6.364 3.678-7.63 3.952-.231.05-.466.05-.696-.002-1.245-.278-5.514-1.39-7.63-3.95C1.907 16.436 1.96 7.268 2.02 4.638a.98.98 0 0 1 .7-.916m4.307 9.256 3.235 3.262a.99.99 0 0 0 1.455-.049l5.423-6.249a1.41 1.41 0 0 0-.063-1.913 1.38 1.38 0 0 0-2.05.094l-4.011 4.855-1.995-2.011a1.4 1.4 0 0 0-1.994 0 1.43 1.43 0 0 0 0 2.011" clip-rule="evenodd"/>
    </svg>;
}
