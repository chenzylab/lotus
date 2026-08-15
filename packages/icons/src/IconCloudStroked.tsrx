/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconCloudStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="M20 11.3V11c0-3.9-3.1-7-7-7-2.8 0-5.2 1.7-6.3 4-3.2.2-5.7 2.8-5.7 6 0 3.3 2.7 6 6 6h11.5c2.5 0 4.5-2 4.5-4.5 0-2-1.3-3.6-3-4.2M18.5 18H7c-2.2 0-4-1.8-4-4 0-1.9 1.3-3.5 3.1-3.9.3-.1.6-.1.9-.1.31 0 .56 0 .844.094.13.042.276-.034.306-.167.13-.586.39-1.106.65-1.627C9.7 6.9 11.2 6 13 6c2.8 0 5 2.2 5 5 0 .6-.147 1.2-.315 1.736-.04.13.056.264.193.264h.622c.4 0 .8.1 1.1.3.8.4 1.4 1.2 1.4 2.2 0 1.4-1.1 2.5-2.5 2.5"/>
    </svg>;
}
