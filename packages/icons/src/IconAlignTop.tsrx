/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconAlignTop(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M11.94 22a1.5 1.5 0 0 1-1.5-1.5v-9.379L8.06 13.5a1.5 1.5 0 1 1-2.12-2.121l4.939-4.94a1.5 1.5 0 0 1 2.121 0l5.06 5.061a1.5 1.5 0 1 1-2.12 2.121l-2.5-2.5V20.5a1.5 1.5 0 0 1-1.5 1.5M19.438 2a1.5 1.5 0 1 1 0 3h-15a1.5 1.5 0 1 1 0-3z" clip-rule="evenodd"/>
    </svg>;
}
