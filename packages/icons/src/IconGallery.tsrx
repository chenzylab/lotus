/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconGallery(props: { class?: string; style?: Record<string, any> }) {
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
        <rect width="18" height="14" x="5" y="9" fill="currentColor" rx="3"/><path fill="currentColor" fill-rule="evenodd" d="M15.659.748 2.463 4.22A3 3 0 0 0 .342 7.946l2.35 8.23q.112.383.308.712V11a4 4 0 0 1 4-4h13.5l-1.193-4.175A3 3 0 0 0 15.659.748" clip-rule="evenodd"/>
    </svg>;
}
