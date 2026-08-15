/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconSaveStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M2 4a2 2 0 0 1 2-2h10.96a2 2 0 0 1 1.415.586l5.04 5.039A2 2 0 0 1 22 9.039V20a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2zm9 0H8v3h3zM6 4v4a1 1 0 0 0 1 1h5a1 1 0 0 0 1-1V4h1.96L20 9.04V20h-2v-5a1 1 0 0 0-1-1H7a1 1 0 0 0-1 1v5H4V4zm10 12v4H8v-4z" clip-rule="evenodd"/>
    </svg>;
}
