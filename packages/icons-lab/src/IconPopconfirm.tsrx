/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconPopconfirm(props: { class?: string; style?: Record<string, any> }) {
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
        <rect width="17" height="14" x="5" y="8" fill="#AAB2BF" rx="2"/><path fill="#DDE3E8" d="M8.465 2.292a.6.6 0 0 0-1.03 0L5.82 5H4a2 2 0 0 0-2 2v10a2 2 0 0 0 2 2h13a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2h-6.921z"/><rect width="4" height="3" x="7" y="13" fill="#4CC3FA" rx="1"/><rect width="4" height="3" x="13" y="13" fill="#324350" rx="1"/>
    </svg>;
}
