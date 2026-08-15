/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconLikeHeart(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M12 6c-1.5-3.876-6.248-3.944-8.596-1.596C.865 6.942 1 10.5 3.5 14c2.021 2.83 6.33 6.314 7.907 7.544a.96.96 0 0 0 1.186 0C14.17 20.314 18.48 16.83 20.5 14c2.5-3.5 2.635-7.058.096-9.596C18.248 2.056 14.5 2.124 12 6" clip-rule="evenodd"/>
    </svg>;
}
