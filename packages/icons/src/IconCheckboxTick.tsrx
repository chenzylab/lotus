/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconCheckboxTick(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M17.411 7.308a1.5 1.5 0 0 1 .28 2.103l-6.5 8.5a1.5 1.5 0 0 1-2.375.01l-3.5-4.5a1.5 1.5 0 1 1 2.368-1.842l2.306 2.965 5.318-6.955a1.5 1.5 0 0 1 2.103-.28" clip-rule="evenodd"/>
    </svg>;
}
