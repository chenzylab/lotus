/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconLink(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" fill-rule="evenodd" d="M12.94 2.94a5.743 5.743 0 1 1 8.12 8.12l-2.668 2.669a7.05 7.05 0 0 0-.397-3.845l.944-.945a2.743 2.743 0 1 0-3.878-3.878l-4 4a2.743 2.743 0 0 0 .9 4.478l-2.203 2.203a5.743 5.743 0 0 1-.82-8.802zm-10 10 2.668-2.669a7.04 7.04 0 0 0 .397 3.845l-.944.945a2.743 2.743 0 1 0 3.878 3.878l4-4a2.742 2.742 0 0 0-.565-4.313L14.53 8.47q.276.216.53.47a5.743 5.743 0 0 1 0 8.12l-4 4a5.743 5.743 0 0 1-8.12-8.12" clip-rule="evenodd"/>
    </svg>;
}
