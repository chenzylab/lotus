/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconAlertTriangle(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="m10.227 2.399-8.7 16.676C.83 20.406 1.796 22 3.298 22h17.402c1.502 0 2.468-1.594 1.773-2.925l-8.7-16.676c-.749-1.434-2.8-1.434-3.547 0m2.915 11.611a1.153 1.153 0 0 1-2.283 0l-.576-4.03a1.735 1.735 0 1 1 3.434 0zm.358 4.49a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0" clip-rule="evenodd"/>
    </svg>;
}
