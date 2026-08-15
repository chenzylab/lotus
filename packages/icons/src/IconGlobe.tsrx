/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconGlobe(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M1 12C1 5.925 5.925 1 12 1s11 4.925 11 11-4.925 11-11 11S1 18.075 1 12m11-8a8 8 0 0 0-8 8h4.714A4.286 4.286 0 0 1 13 16.286c0 .394-.32.714-.714.714H10c-.5 0-.91.5-.91 1.5S10 20 10.5 20H12a8 8 0 0 0 7.907-6.774A4.16 4.16 0 0 1 17.5 14c-1.845 0-3.431-1.234-4.126-3H10c-.552 0-1.01-.451-.91-.995C9.6 7.185 11.5 6 13.866 6.05c.19-.288.407-.554.648-.79.283-.28.233-.785-.147-.903A8 8 0 0 0 12 4" clip-rule="evenodd"/>
    </svg>;
}
