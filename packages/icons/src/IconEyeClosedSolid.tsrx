/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconEyeClosedSolid(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M21.707 3.707a1 1 0 0 0-1.414-1.414l-2.98 2.98A11.6 11.6 0 0 0 12 4C5 4 1 10 1 12c0 1.176 1.382 3.733 3.943 5.642l-2.65 2.65a1 1 0 1 0 1.414 1.415zM7.828 14.757l1.464-1.464a3 3 0 0 1 4.001-4.001l1.464-1.464a5 5 0 0 0-6.929 6.929" clip-rule="evenodd"/><path fill="currentColor" d="M12 20a11.7 11.7 0 0 1-3.384-.495l2.571-2.57Q11.584 17 12 17a5 5 0 0 0 4.934-5.813l3.57-3.569C22.133 9.273 23 11.07 23 12c0 2-4 8-11 8"/>
    </svg>;
}
