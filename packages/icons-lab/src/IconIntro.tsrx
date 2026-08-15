/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconIntro(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="#DDE3E8" d="M3.126 8.1A3 3 0 0 0 2 10.441V19a3 3 0 0 0 3 3h4v-6a3 3 0 1 1 6 0v6h4a3 3 0 0 0 3-3v-8.558a3 3 0 0 0-1.126-2.343L13.25 2a2 2 0 0 0-2.498 0z"/><path fill="#6A6F7F" d="M9 15v7h6v-7a3 3 0 1 0-6 0"/>
    </svg>;
}
