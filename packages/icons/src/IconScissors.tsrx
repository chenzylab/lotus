/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconScissors(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="m13.288 20.087-1.286-2.227-1.298 2.248C10 21.5 8.42 23 6.5 23a4.5 4.5 0 1 1 2.624-8.156l.569-.984L6 6.464a4 4 0 0 1 .645-4.84c.402-.397 1.04-.212 1.307.286l6.927 12.932A4.5 4.5 0 1 1 17.5 23c-1.927 0-3.5-1.5-4.212-2.913M6.5 17A1.496 1.496 0 0 1 8 18.5 1.497 1.497 0 0 1 6.5 20a1.5 1.5 0 0 1 0-3m9.93 2.55a1.5 1.5 0 1 0 2.141-2.101 1.5 1.5 0 0 0-2.142 2.102M12 15a1 1 0 1 0 0-2 1 1 0 0 0 0 2" clip-rule="evenodd"/><path fill="currentColor" d="m15.368 12.03 2.636-5.566a4 4 0 0 0-.622-4.816c-.406-.41-1.059-.21-1.315.307L13.059 8.03z"/>
    </svg>;
}
