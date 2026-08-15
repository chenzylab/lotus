/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconH2(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M3.5 2.5A1.5 1.5 0 0 1 5 4v6.5h6V4a1.5 1.5 0 0 1 3 0v16a1.5 1.5 0 0 1-3 0v-6.5H5V20a1.5 1.5 0 0 1-3 0V4a1.5 1.5 0 0 1 1.5-1.5" clip-rule="evenodd"/><path fill="currentColor" d="M15.467 19.872c0 .67.512 1.128 1.264 1.128h4.765c.807 0 1.285-.41 1.285-1.1s-.492-1.115-1.285-1.115h-2.29v-.11l1.613-1.435c1.087-.964 1.62-1.92 1.62-2.925 0-1.607-1.483-2.803-3.472-2.803-1.907 0-3.514 1.175-3.514 2.508 0 .609.465 1.046 1.121 1.046.458 0 .759-.177 1.176-.697.362-.451.656-.615 1.066-.615.534 0 .903.342.903.848 0 .45-.315.888-1.026 1.558l-2.091 1.969c-.841.786-1.135 1.237-1.135 1.743"/>
    </svg>;
}
