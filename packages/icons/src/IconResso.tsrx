/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconResso(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="M6.55 23a4.32 4.32 0 0 1-4.315-4.314V15.18a4.297 4.297 0 0 1 6.555-3.67l5.59 3.42 3.067-1.878a1.24 1.24 0 0 0 .607-.992 1.22 1.22 0 0 0-.578-1.098L7.5 4.856a1.211 1.211 0 0 0-1.847 1.035v2.636A6.18 6.18 0 0 0 2.23 10.11l.005-4.8A4.298 4.298 0 0 1 8.79 1.64l10.922 6.686a4.306 4.306 0 0 1 0 7.345l-2.059 1.262 2.468 1.51a1.7 1.7 0 0 1 .802 1.695 1.7 1.7 0 0 1-.27.716 1.73 1.73 0 0 1-1.426.76 1.7 1.7 0 0 1-.893-.253l-3.958-2.422-5.586 3.42A4.3 4.3 0 0 1 6.55 23m.453-8.385a1.216 1.216 0 0 0-1.216 1.214v2.345a1.212 1.212 0 0 0 1.847 1.035l3.604-2.207-3.603-2.206a1.2 1.2 0 0 0-.632-.181"/>
    </svg>;
}
