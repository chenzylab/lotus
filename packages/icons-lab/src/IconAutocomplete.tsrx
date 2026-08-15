/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconAutocomplete(props: { class?: string; style?: Record<string, any> }) {
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
        <rect width="22" height="16" x="1" y="4" fill="#DDE3E8" rx="3"/><path fill="#4CC3FA" d="M3.092 16.31c.457 0 .71-.234.888-.831l.483-1.473h3.04l.49 1.473c.17.59.437.832.9.832.49 0 .813-.292.813-.75 0-.177-.044-.387-.133-.66L7.389 8.643C7.116 7.83 6.735 7.5 6.02 7.5c-.725 0-1.112.336-1.385 1.143L2.451 14.9c-.108.324-.153.52-.153.692 0 .432.324.718.794.718m1.752-3.58 1.104-3.503h.083l1.098 3.503z"/><path fill="#AAB2BF" d="M10.931 15.136c0 .737.375 1.098 1.143 1.098h2.463c1.834 0 3.015-.958 3.015-2.444 0-1.18-.762-2.005-1.93-2.113V11.6c.927-.216 1.485-.92 1.485-1.898 0-1.308-.99-2.133-2.564-2.133h-2.47c-.767 0-1.142.368-1.142 1.098zm1.701-3.96V8.857h1.517c.8 0 1.27.432 1.27 1.137 0 .755-.508 1.18-1.657 1.18zm0 3.77v-2.577h1.625c1.003 0 1.55.501 1.55 1.32 0 .825-.553 1.257-1.905 1.257z"/><rect width="2" height="12" x="19" y="6" fill="#324350" rx="1"/>
    </svg>;
}
