/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconEdit(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="m14.5 4.5 5 5 2.086-2.086a2 2 0 0 0 0-2.828l-2.172-2.172a2 2 0 0 0-2.828 0zM2.247 21.135l1.682-5.886a1 1 0 0 1 .254-.432L13 6l5 5-8.817 8.817a1 1 0 0 1-.432.254l-5.886 1.682a.5.5 0 0 1-.618-.618"/>
    </svg>;
}
