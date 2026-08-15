/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconQuit(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M13.5 2.5a1.5 1.5 0 0 0-3 0v9a1.5 1.5 0 0 0 3 0zM6.592 6.105a1.5 1.5 0 0 0-2.03-2.21A10.98 10.98 0 0 0 1 12c0 6.075 4.925 11 11 11s11-4.925 11-11c0-3.208-1.375-6.096-3.563-8.105a1.5 1.5 0 1 0-2.029 2.21 8 8 0 1 1-10.817 0" clip-rule="evenodd"/>
    </svg>;
}
