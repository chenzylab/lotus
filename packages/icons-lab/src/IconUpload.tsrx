/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconUpload(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="#4CC3FA" fill-rule="evenodd" d="m14 2 6 6v12a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2z" clip-rule="evenodd"/><path fill="#fff" fill-rule="evenodd" d="M12.707 9.293a1 1 0 0 0-1.414 0l-3 3a1 1 0 1 0 1.414 1.414L11 12.414V17a1 1 0 1 0 2 0v-4.586l1.293 1.293a1 1 0 0 0 1.414-1.414z" clip-rule="evenodd"/><path fill="#324350" fill-rule="evenodd" d="m20 8-6-6v4a2 2 0 0 0 2 2z" clip-rule="evenodd"/>
    </svg>;
}
