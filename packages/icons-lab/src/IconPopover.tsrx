/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconPopover(props: { class?: string; style?: Record<string, any> }) {
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
        <rect width="13" height="13" x="9" y="9" fill="#6A6F7F" rx="2"/><rect width="12" height="12" x="2" y="7" fill="#AAB2BF" rx="2"/><rect width="11" height="11" x="8" y="2" fill="#DDE3E8" rx="2"/>
    </svg>;
}
