/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconCascader(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="#4CC3FA" d="M2 3.548a1 1 0 0 1 1.411-.911L9 5.157V22l-5.822-2.627A2 2 0 0 1 2 17.55z"/><path fill="#FBCD2C" d="m15 2 5.822 2.627A2 2 0 0 1 22 6.45v14.002a1 1 0 0 1-1.411.911L15 18.843z"/><path fill="#324350" d="M9 5.158 15 2v16.842L9 22z"/>
    </svg>;
}
