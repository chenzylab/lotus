/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconRegExp(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M16.752 1a1.5 1.5 0 0 1 1.5 1.5v2.697l2.168-1.445a1.5 1.5 0 1 1 1.664 2.496L19.456 8l2.628 1.752a1.5 1.5 0 1 1-1.664 2.496l-2.168-1.445V13.5a1.5 1.5 0 0 1-3 0v-2.697l-2.168 1.445a1.5 1.5 0 0 1-1.664-2.496L14.048 8 11.42 6.248a1.5 1.5 0 0 1 1.664-2.496l2.168 1.445V2.5a1.5 1.5 0 0 1 1.5-1.5" clip-rule="evenodd"/><circle cx="6.5" cy="17.5" r="4.5" fill="currentColor"/>
    </svg>;
}
