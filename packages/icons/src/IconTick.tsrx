/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconTick(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M21.352 4.265a1.5 1.5 0 0 1 .383 2.087l-10 14.5a1.5 1.5 0 0 1-2.334.169l-6.5-7a1.5 1.5 0 0 1 2.198-2.042l5.228 5.63 8.938-12.96a1.5 1.5 0 0 1 2.087-.384" clip-rule="evenodd"/>
    </svg>;
}
