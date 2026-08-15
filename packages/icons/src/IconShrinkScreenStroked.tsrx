/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconShrinkScreenStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M3.707 2.293a1 1 0 0 0-1.414 1.414L8.086 9.5H4.5a1 1 0 0 0 0 2h6.003a1 1 0 0 0 .706-.295 1 1 0 0 0 .291-.702V4.5a1 1 0 1 0-2 0v3.586zm8.869 10.824a1 1 0 0 0-.076.38V19.5a1 1 0 1 0 2 0v-3.586l5.793 5.793a1 1 0 0 0 1.414-1.414L15.914 14.5H19.5a1 1 0 1 0 0-2h-6.003a1 1 0 0 0-.697.286l-.014.014a1 1 0 0 0-.21.317" clip-rule="evenodd"/>
    </svg>;
}
