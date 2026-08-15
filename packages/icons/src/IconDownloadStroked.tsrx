/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconDownloadStroked(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M13 4a1 1 0 1 0-2 0v9.586l-2.793-2.793a1 1 0 0 0-1.414 1.414l4.5 4.5a1 1 0 0 0 .704.293h.006c.272 0 .518-.11.698-.286l.007-.008 4.5-4.499a1 1 0 0 0-1.415-1.414L13 13.586zm8 9a1 1 0 0 1 1 1v7a1 1 0 0 1-1 1H3a1 1 0 0 1-1-1v-6.997a1 1 0 1 1 2 0V20h16v-6a1 1 0 0 1 1-1" clip-rule="evenodd"/>
    </svg>;
}
