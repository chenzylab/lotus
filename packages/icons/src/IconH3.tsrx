/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconH3(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M3.5 2.5A1.5 1.5 0 0 1 5 4v6.5h6V4a1.5 1.5 0 0 1 3 0v16a1.5 1.5 0 0 1-3 0v-6.5H5V20a1.5 1.5 0 0 1-3 0V4a1.5 1.5 0 0 1 1.5-1.5" clip-rule="evenodd"/><path fill="currentColor" d="M15.214 18.956c0 1.244 1.6 2.25 3.582 2.25 2.297 0 3.93-1.19 3.93-2.865 0-1.197-.806-2.113-1.913-2.174v-.191c.936-.09 1.674-.937 1.674-1.921 0-1.504-1.497-2.543-3.664-2.543-1.941 0-3.575.977-3.575 2.14 0 .594.479 1.032 1.128 1.032a1.5 1.5 0 0 0 1.06-.431c.499-.472.881-.656 1.346-.656.602 0 1.032.335 1.032.8 0 .464-.437.806-1.032.806h-.376c-.567 0-.97.458-.97 1.04 0 .614.403 1.052.97 1.052h.376c.725 0 1.203.37 1.203.916 0 .547-.478.91-1.203.91-.506 0-.95-.213-1.401-.684-.383-.397-.725-.575-1.108-.575-.615 0-1.06.458-1.06 1.094"/>
    </svg>;
}
