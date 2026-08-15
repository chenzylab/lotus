/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconBackward(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="M12 18.036a1 1 0 0 1-1.588.809l-8.3-6.036a1 1 0 0 1 0-1.618l8.3-6.036A1 1 0 0 1 12 5.964zM23 18.036a1 1 0 0 1-1.588.809l-8.3-6.036a1 1 0 0 1 0-1.618l8.3-6.036A1 1 0 0 1 23 5.964z"/>
    </svg>;
}
