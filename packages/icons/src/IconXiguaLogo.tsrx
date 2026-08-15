/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconXiguaLogo(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M23 12c0 6.075-4.925 11-11 11q-.36 0-.716-.023c-1.41-.09-2.283-1.397-2.56-2.783-.52-2.603-2.03-4.335-4.918-4.916-1.386-.279-2.693-1.152-2.783-2.562A11 11 0 0 1 1 12C1 5.925 5.925 1 12 1s11 4.925 11 11m-6.58.931c.561-.595.567-1.498.003-2.09-.595-.626-1.454-1.43-2.486-2.112-.96-.634-2-.972-2.831-1.153-.945-.205-1.82.406-2.032 1.35-.186.827-.363 1.892-.363 2.96 0 1.007.157 2.01.33 2.814.22 1.016 1.193 1.64 2.203 1.396.845-.205 1.857-.535 2.693-1.052.957-.591 1.852-1.443 2.483-2.113" clip-rule="evenodd"/>
    </svg>;
}
