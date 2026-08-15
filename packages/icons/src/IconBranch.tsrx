/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconBranch(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M11 4.5a3.5 3.5 0 0 1-2 3.163v5.32c2.156-.058 4.034-.271 5.442-.911.818-.372 1.425-.867 1.841-1.532a4 4 0 0 0 .132-.228 3.5 3.5 0 1 1 3.031.559q-.251.673-.62 1.26c-.787 1.258-1.899 2.107-3.143 2.672-1.966.894-4.38 1.127-6.683 1.181v.353a3.5 3.5 0 1 1-3 0V7.663A3.5 3.5 0 1 1 11 4.5" clip-rule="evenodd"/>
    </svg>;
}
