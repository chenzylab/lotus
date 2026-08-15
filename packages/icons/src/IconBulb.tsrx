/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconBulb(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M20 9A8 8 0 1 0 4 9c0 3.579 2.333 5.774 3.435 6.611l.426 2.553a1 1 0 0 0 .986.836h6.306a1 1 0 0 0 .986-.836l.443-2.656C17.692 14.5 20 12.038 20 9M8.293 7.293a1 1 0 0 1 1.414 0L12 9.586l2.293-2.293a1 1 0 1 1 1.414 1.414L13 11.414V14.5a1 1 0 1 1-2 0v-3.086L8.293 8.707a1 1 0 0 1 0-1.414M15 20v1a2 2 0 0 1-2 2h-2a2 2 0 0 1-2-2v-1z" clip-rule="evenodd"/>
    </svg>;
}
