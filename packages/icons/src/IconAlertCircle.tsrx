/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconAlertCircle(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M23 12c0 6.075-4.925 11-11 11S1 18.075 1 12 5.925 1 12 1s11 4.925 11 11m-9.5 5.5a1.5 1.5 0 1 0-3 0 1.5 1.5 0 0 0 3 0M12 5c-1.086 0-1.95.912-1.89 1.997l.307 5.505a1.586 1.586 0 0 0 3.166 0l.306-5.505A1.89 1.89 0 0 0 12 5" clip-rule="evenodd"/>
    </svg>;
}
