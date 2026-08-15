/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconTypograph(props: { class?: string; style?: Record<string, any> }) {
    return <svg
        viewBox="0 0 22 22"
        fill="none"
        width="1em"
        height="1em"
        class={props.class}
        style={props.style}
        aria-hidden={true}
        xmlns="http://www.w3.org/2000/svg"
    >
        <path fill="currentColor" d="m3.591 15.566.85-2.637h4.127l.849 2.637h2.591L8.065 4H4.95L1 15.566zm1.464-4.546 1.407-4.377h.09l1.407 4.377zM16.806 19C19.257 19 21 17.87 21 15.651v-8.76h-2.363V8.35h-.089c-.318-.706-1.016-1.57-2.452-1.57-1.882 0-3.473 1.48-3.473 4.433 0 2.886 1.547 4.23 3.479 4.23 1.368 0 2.133-.695 2.446-1.412h.1v1.587c0 1.192-.753 1.655-1.787 1.655-1.05 0-1.58-.463-1.776-.988l-2.2.299C13.17 17.95 14.493 19 16.805 19m.05-5.365c-1.167 0-1.804-.938-1.804-2.434 0-1.474.626-2.508 1.804-2.508 1.156 0 1.804.988 1.804 2.508 0 1.53-.66 2.434-1.804 2.434"/>
    </svg>;
}
