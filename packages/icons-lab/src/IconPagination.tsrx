/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconPagination(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="#6A6F7F" d="M1 8a3 3 0 0 1 3-3h8v14H4a3 3 0 0 1-3-3z"/><path stroke="#fff" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m8 9-3 3 3 3"/><path fill="#DDE3E8" d="M12 5h8a3 3 0 0 1 3 3v8a3 3 0 0 1-3 3h-8z"/><path stroke="#AAB2BF" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m16 9 3 3-3 3"/>
    </svg>;
}
