/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconSlider(props: { class?: string; style?: Record<string, any> }) {
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
        <rect width="17" height="2" x="5" y="4" fill="#AAB2BF" rx="1"/><rect width="18" height="2" x="2" y="11" fill="#4CC3FA" rx="1"/><rect width="17" height="2" x="5" y="18" fill="#AAB2BF" rx="1"/><circle cx="5.5" cy="5" r="3.5" fill="#DDE3E8"/><circle cx="18.5" cy="12" r="3.5" fill="#DDE3E8"/><circle cx="5.5" cy="19" r="3.5" fill="#DDE3E8"/>
    </svg>;
}
