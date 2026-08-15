/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconQuote(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M9.934 4.933a1.5 1.5 0 0 1-.993 1.874 7.02 7.02 0 0 0-4.078 3.323Q5.412 10 6 10a5 5 0 1 1-5 5v-1.5c0-4.502 2.973-8.305 7.06-9.56a1.5 1.5 0 0 1 1.874.993m12 0a1.5 1.5 0 0 1-.993 1.874 7.02 7.02 0 0 0-4.078 3.323Q17.412 10 18 10a5 5 0 1 1-5 5v-1.5c0-4.502 2.973-8.305 7.06-9.56a1.5 1.5 0 0 1 1.874.993" clip-rule="evenodd"/>
    </svg>;
}
