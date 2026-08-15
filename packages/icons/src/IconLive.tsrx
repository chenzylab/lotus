/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconLive(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M8.06 1.94a1.5 1.5 0 1 0-2.12 2.12L7.878 6H5a3 3 0 0 0-3 3v10a3 3 0 0 0 3 3h14a3 3 0 0 0 3-3V9a3 3 0 0 0-3-3h-2.879l1.94-1.94a1.5 1.5 0 0 0-2.122-2.12L12 5.878zM10 10.933v6.132a.5.5 0 0 0 .777.416l4.599-3.066a.5.5 0 0 0 0-.832l-4.599-3.066a.5.5 0 0 0-.777.416" clip-rule="evenodd"/>
    </svg>;
}
