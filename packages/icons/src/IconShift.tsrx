/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconShift(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M12 1a1.5 1.5 0 0 1 1.152.54l10 12A1.5 1.5 0 0 1 22 16h-4v5.5a1.5 1.5 0 0 1-1.5 1.5h-9A1.5 1.5 0 0 1 6 21.5V16H2a1.5 1.5 0 0 1-1.152-2.46l10-12A1.5 1.5 0 0 1 12 1M5.203 13H9v7h6v-7h3.797L12 4.843z" clip-rule="evenodd"/>
    </svg>;
}
