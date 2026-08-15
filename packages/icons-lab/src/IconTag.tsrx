/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconTag(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="#F82C2C" fill-rule="evenodd" d="M13.243 3.343a4 4 0 0 0-2.829 1.172l-8.728 8.728a2 2 0 0 0 0 2.828l5.657 5.657a2 2 0 0 0 2.829 0L18.9 13a4 4 0 0 0 1.171-2.828V5.343a2 2 0 0 0-2-2zM13 7.586a2 2 0 1 0 2.828 2.828A2 2 0 0 0 13 7.586" clip-rule="evenodd"/><path stroke="#AAB2BF" stroke-linecap="round" stroke-width="1.5" d="M14.85 8.4c1.2-1.5 4.85-3.7 6.65-1.9 2.25 2.25-1.5 6-1.5 9.5 0 2.474 2.15 3 2.85 3"/>
    </svg>;
}
