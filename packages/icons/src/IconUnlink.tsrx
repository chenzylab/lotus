/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconUnlink(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M12.94 2.94a5.743 5.743 0 1 1 8.12 8.12l-3.55 3.55-2.12-2.12 3.55-3.55a2.743 2.743 0 1 0-3.88-3.88l-3.55 3.55L9.39 6.49zm-10 10 3.05-3.05 2.12 2.12-3.05 3.05a2.743 2.743 0 0 0 3.88 3.88l3.05-3.05 2.12 2.12-3.05 3.05a5.743 5.743 0 1 1-8.12-8.12" clip-rule="evenodd"/><path fill="currentColor" d="m5.379 7.5 1.414-1.414 2.722 2.722-1.414 1.414zM13.779 15.9l1.414-1.414 2.72 2.721-1.413 1.414z"/>
    </svg>;
}
