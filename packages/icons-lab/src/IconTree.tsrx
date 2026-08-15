/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconTree(props: { class?: string; style?: Record<string, any> }) {
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
        <rect width="13" height="5" x="9" y="16" fill="#6A6F7F" rx=".5"/><rect width="13" height="5" x="9" y="9" fill="#6A6F7F" rx=".5"/><path fill="#AAB2BF" fill-rule="evenodd" d="M5 6a1 1 0 0 1 1 1v11h1a1 1 0 1 1 0 2H5a1 1 0 0 1-1-1V7a1 1 0 0 1 1-1" clip-rule="evenodd"/><path fill="#AAB2BF" fill-rule="evenodd" d="M5 12a1 1 0 0 1 1-1h1a1 1 0 1 1 0 2H6a1 1 0 0 1-1-1" clip-rule="evenodd"/><rect width="15" height="5" x="2" y="2" fill="#4CC3FA" rx=".5"/>
    </svg>;
}
