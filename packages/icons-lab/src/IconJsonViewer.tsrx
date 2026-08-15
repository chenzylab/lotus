/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconJsonViewer(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="#DDE3E8" d="M2 5a3 3 0 0 1 3-3h12a3 3 0 0 1 3 3v10a3 3 0 0 1-3 3H5a3 3 0 0 1-3-3z"/><path fill="#AAB2BF" fill-rule="evenodd" d="M12.16 4.984a.875.875 0 1 0-1.736-.217L9.257 14.1a.875.875 0 0 0 1.736.217zm.846 1.022a.875.875 0 0 1 1.238 0l2.916 2.917a.875.875 0 0 1 0 1.238l-2.916 2.916a.875.875 0 1 1-1.238-1.237l2.298-2.298-2.298-2.298a.875.875 0 0 1 0-1.238" clip-rule="evenodd"/><path fill="#4CC3FA" fill-rule="evenodd" d="M13.006 6.006a.875.875 0 0 1 1.238 0l2.916 2.917a.875.875 0 0 1 0 1.237l-2.916 2.917a.875.875 0 1 1-1.238-1.237l2.298-2.298-2.298-2.298a.875.875 0 0 1 0-1.238" clip-rule="evenodd"/><path fill="#FBCD2C" fill-rule="evenodd" d="M8.41 6.006a.875.875 0 0 0-1.237 0L4.256 8.923a.875.875 0 0 0 0 1.237l2.917 2.917A.875.875 0 1 0 8.41 11.84L6.112 9.542 8.41 7.244a.875.875 0 0 0 0-1.238" clip-rule="evenodd"/><path fill="#6A6F7F" d="m18.458 11.625 2.917 2.916 1.217-1.216a1.167 1.167 0 0 0 0-1.65l-1.267-1.267a1.167 1.167 0 0 0-1.65 0zM11.31 21.328l.982-3.433a.6.6 0 0 1 .148-.252l5.143-5.143 2.917 2.916-5.143 5.144a.6.6 0 0 1-.252.148l-3.434.98a.292.292 0 0 1-.36-.36"/>
    </svg>;
}
