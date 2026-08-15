/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconHn(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M3.5 2.5A1.5 1.5 0 0 1 5 4v6.5h6V4a1.5 1.5 0 0 1 3 0v16a1.5 1.5 0 0 1-3 0v-6.5H5V20a1.5 1.5 0 0 1-3 0V4a1.5 1.5 0 0 1 1.5-1.5" clip-rule="evenodd"/><path fill="currentColor" d="M22.378 19.565v-3.337c0-1.729-.861-2.7-2.393-2.7-1.005 0-1.873.554-2.126 1.34h-.136c-.048-.848-.52-1.292-1.333-1.292-.828 0-1.347.547-1.347 1.45v4.525c0 .984.492 1.517 1.395 1.517.895 0 1.38-.533 1.38-1.517v-2.605c0-.71.363-1.155.903-1.155.547 0 .881.444.881 1.135v2.625c0 .984.486 1.517 1.388 1.517.896 0 1.388-.52 1.388-1.504"/>
    </svg>;
}
