/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconWholeWord(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M7.5 5a1.5 1.5 0 0 1 1.41.987l4 11a1.5 1.5 0 1 1-2.82 1.026L9.54 16.5H5.46l-.55 1.513a1.5 1.5 0 1 1-2.82-1.026l4-11A1.5 1.5 0 0 1 7.5 5m-.95 8.5h1.9l-.95-2.61zM2 3a1 1 0 0 1 1-1h18a1 1 0 1 1 0 2H3a1 1 0 0 1-1-1M1.987 21a1 1 0 0 1 1-1H21a1 1 0 1 1 0 2H2.987a1 1 0 0 1-1-1M15.5 5A1.5 1.5 0 0 1 17 6.5V10c1.226 0 2.457.337 3.414 1.105.992.797 1.586 1.98 1.586 3.395s-.593 2.598-1.586 3.395C19.457 18.663 18.226 19 17 19h-2a1 1 0 0 1-1-1V6.5A1.5 1.5 0 0 1 15.5 5m1.5 8v3c.707 0 1.226-.196 1.536-.445.274-.22.464-.537.464-1.055s-.19-.835-.464-1.055c-.31-.249-.83-.445-1.536-.445" clip-rule="evenodd"/>
    </svg>;
}
