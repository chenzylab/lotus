/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconCommand(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M6.227 5C5.55 5 5 5.55 5 6.227 5 7.207 5.794 8 6.773 8H8V6.5A1.5 1.5 0 0 0 6.5 5zM11 8V6.5A4.5 4.5 0 0 0 6.5 2h-.273A4.227 4.227 0 0 0 2 6.227 4.773 4.773 0 0 0 6.773 11H8v2H6.227A4.227 4.227 0 0 0 2 17.227v.273a4.5 4.5 0 1 0 9 0V16h2v1.5a4.5 4.5 0 1 0 9 0v-.273A4.227 4.227 0 0 0 17.773 13H16v-2h1.227A4.773 4.773 0 0 0 22 6.227 4.227 4.227 0 0 0 17.773 2H17.5A4.5 4.5 0 0 0 13 6.5V8zm0 3v2h2v-2zm5-3h1.227C18.207 8 19 7.206 19 6.227 19 5.55 18.45 5 17.773 5H17.5A1.5 1.5 0 0 0 16 6.5zm0 8v1.5a1.5 1.5 0 0 0 3 0v-.273C19 16.55 18.45 16 17.773 16zm-8 0H6.227C5.55 16 5 16.55 5 17.227v.273a1.5 1.5 0 0 0 3 0z" clip-rule="evenodd"/>
    </svg>;
}
