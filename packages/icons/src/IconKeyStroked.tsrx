/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconKeyStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M15.333 4c-2.605 0-4.666 2.043-4.666 4.5 0 .62.129 1.208.363 1.743l.267.612L5 17.403V20h2.121v-2.5h2.576V15h2.576v-2.375h1c.1 0 .187.016.207.02h.003q.056.01.1.02c.058.014.128.03.198.048l.06.015q.201.05.455.11c.411.094.799.162 1.037.162C17.94 13 20 10.957 20 8.5S17.939 4 15.333 4M8.667 8.5c0-3.618 3.013-6.5 6.666-6.5S22 4.882 22 8.5 18.987 15 15.333 15c-.337 0-.72-.057-1.06-.123V17h-2.576v2.5H9.121V22H3v-5.403l5.957-6.195a6.4 6.4 0 0 1-.29-1.902M17 8.5a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0" clip-rule="evenodd"/>
    </svg>;
}
