/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconCartStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="M9.654 18a2 2 0 1 1 0 4.001 2 2 0 0 1 0-4.001M18.654 18a2 2 0 1 1 0 4 2 2 0 0 1 0-4"/><path fill="currentColor" fill-rule="evenodd" d="M5.492 2A1.5 1.5 0 0 1 6.94 3.11l.03.132.136.784h14.717a1 1 0 0 1 .977 1.217l-1.556 7a1 1 0 0 1-.804.769l-.172.014H8.674L9.017 15h11.145a1 1 0 0 1 0 2H8.597a1.5 1.5 0 0 1-1.478-1.242L5.276 5.199l-.009-.072L5.071 4H2.177a1 1 0 0 1 0-2zM7.81 8.07l.519 2.956h11.137l1.11-5H7.456z" clip-rule="evenodd"/>
    </svg>;
}
