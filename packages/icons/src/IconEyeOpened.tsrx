/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconEyeOpened(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M12 4C5 4 1 10 1 12s4 8 11 8 11-6 11-8-4-8-11-8m5 8a5 5 0 1 1-10 0 5 5 0 0 1 10 0m-5 3a3 3 0 1 0 0-6 3 3 0 0 0 0 6" clip-rule="evenodd"/>
    </svg>;
}
