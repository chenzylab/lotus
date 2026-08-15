/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconBolt(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="M3.6 14.2 15.103.65c.303-.405.947-.154.897.35l-2 8h6a.5.5 0 0 1 .4.8L8.898 23.35c-.304.405-.948.154-.898-.35l2-8H4a.5.5 0 0 1-.4-.8"/>
    </svg>;
}
