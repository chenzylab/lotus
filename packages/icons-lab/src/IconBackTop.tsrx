/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconBackTop(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="#4CC3FA" d="M2.969 14.128 12 6l9.032 8.128a.5.5 0 0 1-.335.872H16v7H8v-7H3.303a.5.5 0 0 1-.334-.872"/><rect width="18" height="4" x="3" y="2" fill="#AAB2BF" rx="1"/>
    </svg>;
}
