/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconConfig(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="#DDE3E8" fill-rule="evenodd" d="M10.298 1a1 1 0 0 0-.975.778l-.671 2.954a8 8 0 0 0-1.27.735L4.486 4.57a1 1 0 0 0-1.161.455L1.623 7.974a1 1 0 0 0 .186 1.233l2.224 2.06a8 8 0 0 0 0 1.466l-2.224 2.06a1 1 0 0 0-.186 1.233l1.702 2.948a1 1 0 0 0 1.161.455l2.896-.896q.598.424 1.27.735l.671 2.954a1 1 0 0 0 .975.778h3.404a1 1 0 0 0 .975-.778l.671-2.954a8 8 0 0 0 1.27-.735l2.896.896a1 1 0 0 0 1.162-.455l1.701-2.948a1 1 0 0 0-.186-1.233l-2.224-2.06a8 8 0 0 0 0-1.466l2.224-2.06a1 1 0 0 0 .186-1.233l-1.701-2.948a1 1 0 0 0-1.162-.455l-2.896.896a8 8 0 0 0-1.27-.735l-.671-2.954A1 1 0 0 0 13.702 1z" clip-rule="evenodd"/><path fill="#AAB2BF" fill-rule="evenodd" d="M12 16a4 4 0 1 0 0-8 4 4 0 0 0 0 8m0 2a6 6 0 1 0 0-12 6 6 0 0 0 0 12" clip-rule="evenodd"/><circle cx="12" cy="12" r="3" fill="#324350"/>
    </svg>;
}
