/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconTagInput(props: { class?: string; style?: Record<string, any> }) {
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
        <rect width="22" height="16" x="1" y="4" fill="#DDE3E8" rx="2"/><path fill="#AAB2BF" d="M4.092 16.405c.457 0 .71-.235.888-.831l.483-1.473h3.04l.49 1.473c.17.59.437.831.9.831.49 0 .813-.292.813-.749 0-.178-.044-.387-.133-.66L8.389 8.737c-.273-.812-.654-1.142-1.37-1.142-.725 0-1.112.336-1.385 1.142l-2.183 6.26c-.108.323-.153.52-.153.691 0 .432.324.717.794.717m1.752-3.58 1.104-3.504h.083l1.098 3.504z"/><path fill="#324350" d="M20.121 9.879a1 1 0 0 0-1.414 0l-.707.707-.707-.707a1 1 0 1 0-1.414 1.414l.707.707-.707.707a1 1 0 0 0 1.414 1.414l.707-.707.707.707a1 1 0 0 0 1.414-1.414L19.414 12l.707-.707a1 1 0 0 0 0-1.414"/>
    </svg>;
}
