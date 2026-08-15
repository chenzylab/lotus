/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconInputNumber(props: { class?: string; style?: Record<string, any> }) {
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
        <rect width="22" height="16" x="1" y="4" fill="#DDE3E8" rx="3"/><path fill="#4CC3FA" d="M15 4h5a3 3 0 0 1 3 3v10a3 3 0 0 1-3 3h-5z"/><path fill="#fff" d="m19 7.5 2 3h-4zM19 16.5l-2-3h4z"/><path fill="#324350" d="M8.358 15.776c-.965 0-1.65-.597-1.65-1.422 0-.831.685-1.435 1.65-1.435.958 0 1.65.604 1.65 1.435 0 .825-.692 1.422-1.65 1.422m0-4.05c-.8 0-1.371-.527-1.371-1.25 0-.718.571-1.232 1.37-1.232s1.372.514 1.372 1.232c0 .73-.571 1.25-1.371 1.25m-.02 5.288c2.007 0 3.372-1.035 3.372-2.552 0-1.066-.73-1.93-1.816-2.152v-.095c.927-.286 1.473-1.01 1.473-1.924C11.367 8.946 10.129 8 8.357 8c-1.77 0-3.008.946-3.008 2.291 0 .92.54 1.638 1.466 1.924v.095C5.724 12.532 5 13.395 5 14.468c0 1.524 1.34 2.546 3.339 2.546"/>
    </svg>;
}
