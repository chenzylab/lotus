/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconH6(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M3.5 2.5A1.5 1.5 0 0 1 5 4v6.5h6V4a1.5 1.5 0 0 1 3 0v16a1.5 1.5 0 0 1-3 0v-6.5H5V20a1.5 1.5 0 0 1-3 0V4a1.5 1.5 0 0 1 1.5-1.5" clip-rule="evenodd"/><path fill="currentColor" d="M14.954 16.297c0 1.49.37 2.762 1.066 3.61.698.854 1.716 1.298 2.96 1.298 2.202 0 3.692-1.353 3.692-3.404 0-1.77-1.176-3.001-2.864-3.001-.971 0-1.812.506-2.147 1.292H17.6c0-1.566.533-2.44 1.572-2.44.383 0 .677.095 1.107.369.445.28.711.375 1.06.375.622 0 1.046-.382 1.046-.957 0-.458-.315-.943-.841-1.298-.615-.41-1.456-.63-2.406-.63-2.666 0-4.184 1.737-4.184 4.786m2.94 1.606c0-.663.458-1.155 1.066-1.155.601 0 1.039.485 1.039 1.155 0 .698-.437 1.176-1.039 1.176-.608 0-1.066-.485-1.066-1.176"/>
    </svg>;
}
