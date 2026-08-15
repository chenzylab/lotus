/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconInput(props: { class?: string; style?: Record<string, any> }) {
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
        <path stroke="#AAB2BF" stroke-linecap="round" stroke-width="2" d="M12 8.5S12.5 6 11 4 8 2 8 2"/><rect width="22" height="15" x="1" y="6" fill="#DDE3E8" rx="2"/><rect width="3" height="3" x="3" y="8" fill="#6A6F7F" rx="1.5"/><rect width="3" height="3" x="8" y="8" fill="#6A6F7F" rx="1.5"/><rect width="3" height="3" x="13" y="8" fill="#6A6F7F" rx="1.5"/><rect width="3" height="3" x="18" y="8" fill="#6A6F7F" rx="1.5"/><rect width="3" height="3" x="3" y="12" fill="#6A6F7F" rx="1.5"/><rect width="3" height="3" x="8" y="12" fill="#6A6F7F" rx="1.5"/><rect width="3" height="3" x="13" y="12" fill="#6A6F7F" rx="1.5"/><rect width="3" height="3" x="18" y="12" fill="#6A6F7F" rx="1.5"/><rect width="12" height="2" x="6" y="17" fill="#6A6F7F" rx="1"/>
    </svg>;
}
