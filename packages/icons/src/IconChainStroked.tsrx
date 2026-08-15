/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconChainStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M18.364 5.636a3 3 0 0 0-4.243 0L12 7.757a1 1 0 1 1-1.414-1.414l2.121-2.121a5 5 0 0 1 7.071 7.07l-2.121 2.122A1 1 0 0 1 16.243 12l2.121-2.121a3 3 0 0 0 0-4.243M5.636 18.364a3 3 0 0 0 4.243 0L12 16.242a1 1 0 0 1 1.414 1.415l-2.121 2.121a5 5 0 0 1-7.071-7.071l2.121-2.121A1 1 0 0 1 7.757 12L5.636 14.12a3 3 0 0 0 0 4.243m9.9-8.486a1 1 0 0 0-1.415-1.414l-5.656 5.657a1 1 0 1 0 1.414 1.414z" clip-rule="evenodd"/>
    </svg>;
}
