/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconSelect(props: { class?: string; style?: Record<string, any> }) {
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
        <g clip-path="url(#a)"><rect width="16" height="5" x="2" y="2" fill="#DDE3E8" rx=".5"/><rect width="16" height="5" x="2" y="17" fill="#DDE3E8" rx=".5"/><rect width="16" height="6" x="6" y="9" fill="#FBCD2C" rx=".5"/><path fill="#fff" fill-rule="evenodd" d="M12.5 10.793c0-.891 1.077-1.337 1.707-.707l8.707 8.707c.63.63.184 1.707-.707 1.707H18.25a2 2 0 0 0-1.49.667l-2.514 2.809c-.612.684-1.745.25-1.745-.667zM16.684 19H21l-7-7v10z" clip-rule="evenodd"/><path fill="#324350" d="M14 22V12l7 7h-4.316z"/></g><defs><clipPath id="a"><path fill="#fff" d="M0 0h24v24H0z"/></clipPath></defs>
    </svg>;
}
