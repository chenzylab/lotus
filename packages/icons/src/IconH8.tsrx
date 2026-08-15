/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconH8(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M3.5 2.5A1.5 1.5 0 0 1 5 4v6.5h6V4a1.5 1.5 0 0 1 3 0v16a1.5 1.5 0 0 1-3 0v-6.5H5V20a1.5 1.5 0 0 1-3 0V4a1.5 1.5 0 0 1 1.5-1.5" clip-rule="evenodd"/><path fill="currentColor" d="M18.618 19.346c-.718 0-1.23-.479-1.23-1.142 0-.67.512-1.148 1.23-1.148s1.238.485 1.238 1.148-.52 1.142-1.238 1.142m0-4.047c-.58 0-1.005-.41-1.005-.964s.424-.964 1.005-.964 1.012.41 1.012.964-.43.964-1.012.964m0 5.906c2.509 0 4.109-1.073 4.109-2.755 0-1.21-.8-2.092-2.072-2.283v-.157c1.142-.322 1.696-1.005 1.696-2.065 0-1.463-1.49-2.433-3.733-2.433-2.242 0-3.732.97-3.732 2.433 0 1.06.554 1.743 1.695 2.065v.157c-1.271.191-2.071 1.073-2.071 2.283 0 1.682 1.6 2.755 4.108 2.755"/>
    </svg>;
}
