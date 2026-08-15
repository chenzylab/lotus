/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconAlarm(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="m3.475 6 2.5-2.5a1.768 1.768 0 1 0-2.5-2.5l-2.5 2.5a1.768 1.768 0 0 0 2.5 2.5" clip-rule="evenodd"/><path fill="currentColor" fill-rule="evenodd" d="M12 23c5.523 0 10-4.477 10-10S17.523 3 12 3 2 7.477 2 13s4.477 10 10 10m1.5-15v4.073L17 14a1.5 1.5 0 1 1-1.342 2.683l-4.329-2.341A1.5 1.5 0 0 1 10.5 13V8a1.5 1.5 0 0 1 3 0" clip-rule="evenodd"/><path fill="currentColor" fill-rule="evenodd" d="M18 3.5 20.5 6A1.768 1.768 0 0 0 23 3.5L20.5 1A1.768 1.768 0 1 0 18 3.5" clip-rule="evenodd"/>
    </svg>;
}
