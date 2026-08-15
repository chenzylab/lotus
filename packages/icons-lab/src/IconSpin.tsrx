/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconSpin(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="#AAB2BF" d="M13.5 2.5a1.5 1.5 0 0 0-3 0v4a1.5 1.5 0 0 0 3 0zM13.5 17.5a1.5 1.5 0 0 0-3 0v4a1.5 1.5 0 0 0 3 0zM4.523 5.951a1.5 1.5 0 1 0-1.5 2.598l3.464 2a1.5 1.5 0 0 0 1.5-2.598zM17.513 13.451a1.5 1.5 0 0 0-1.5 2.598l3.464 2a1.5 1.5 0 1 0 1.5-2.598zM3.023 15.451a1.5 1.5 0 1 0 1.5 2.598l3.464-2a1.5 1.5 0 1 0-1.5-2.598z"/><path fill="#FF7D95" d="M16.013 7.951a1.5 1.5 0 0 0 1.5 2.598l3.464-2a1.5 1.5 0 1 0-1.5-2.598z"/>
    </svg>;
}
