/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconCollapsible(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="#DDE3E8" d="M2.724 5.447A1 1 0 0 1 3.618 4h16.764a1 1 0 0 1 .894 1.447L18 12H6z"/><path fill="#6A6F7F" d="M2.724 18.553A1 1 0 0 0 3.618 20h16.764a1 1 0 0 0 .894-1.447L18 12H6z"/><path stroke="#4CC3FA" stroke-linecap="round" stroke-width="2" d="M12 2v8"/><path stroke="#4CC3FA" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m9 7 3 3 3-3"/><path stroke="#4CC3FA" stroke-linecap="round" stroke-width="2" d="M12 22v-8"/><path stroke="#4CC3FA" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m9 17 3-3 3 3"/>
    </svg>;
}
