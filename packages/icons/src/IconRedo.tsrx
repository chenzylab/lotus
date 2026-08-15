/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconRedo(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M14.44 2.44a1.5 1.5 0 0 0 0 2.12L16.878 7H9.25C5.165 7 2 10.58 2 14.5S5.165 22 9.25 22h3.25a1.5 1.5 0 0 0 0-3H9.25C6.984 19 5 16.93 5 14.5S6.984 10 9.25 10h7.629l-2.44 2.44a1.5 1.5 0 0 0 2.122 2.12l5-5a1.5 1.5 0 0 0 0-2.12l-5-5a1.5 1.5 0 0 0-2.122 0" clip-rule="evenodd"/>
    </svg>;
}
