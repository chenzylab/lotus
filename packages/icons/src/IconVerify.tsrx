/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconVerify(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M1.414 10.586 3.5 8.5v-3a2 2 0 0 1 2-2h3l2.086-2.086a2 2 0 0 1 2.828 0L15.5 3.5h3a2 2 0 0 1 2 2v3l2.086 2.086a2 2 0 0 1 0 2.828L20.5 15.5v3a2 2 0 0 1-2 2h-3l-2.086 2.086a2 2 0 0 1-2.828 0L8.5 20.5h-3a2 2 0 0 1-2-2v-3l-2.086-2.086a2 2 0 0 1 0-2.828M7 13l3.244 3.244a1 1 0 0 0 1.46-.048l5.438-6.215a1.393 1.393 0 1 0-2.118-1.81L11 13l-2-2a1.414 1.414 0 1 0-2 2" clip-rule="evenodd"/>
    </svg>;
}
