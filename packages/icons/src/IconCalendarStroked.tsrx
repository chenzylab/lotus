/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconCalendarStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M9.652 2.112a1.112 1.112 0 1 0-2.225 0v.866H3.101c-1.16 0-2.101.94-2.101 2.1V20.9C1 22.059 1.94 23 3.101 23H20.9c1.16 0 2.101-.94 2.101-2.101V5.079c0-1.16-.94-2.101-2.101-2.101h-4.326v-.866a1.112 1.112 0 1 0-2.225 0v.866H9.652zm6.921 18.663h4.202v-3.708h-4.202zm0-5.932h4.202v-3.708h-4.202zm-2.225-3.708v3.708H9.652v-3.708zm1.113-2.225h5.314V5.202h-4.202v.865a1.112 1.112 0 1 1-2.225 0v-.865H9.652v.865a1.112 1.112 0 0 1-2.225 0v-.865H3.225V8.91H15.46m-1.113 8.157v3.708H9.652v-3.708zm-6.921 3.708v-3.708H3.225v3.708zm0-5.932v-3.708H3.225v3.708z" clip-rule="evenodd"/>
    </svg>;
}
