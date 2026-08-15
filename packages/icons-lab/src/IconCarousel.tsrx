/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconCarousel(props: { class?: string; style?: Record<string, any> }) {
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
        <rect width="11" height="11" x="10.5" y="7.5" fill="#DDE3E8" rx="2"/><rect width="12" height="11" x="2.5" y="7.5" fill="#AAB2BF" rx="2"/><rect width="14" height="13" x="5" y="5.5" fill="#6A6F7F" rx="2"/><path fill="#DDE3E8" d="M12.182 10.706c.586-.941 2.05-.941 2.636 0l1.976 3.176c.585.941-.146 2.118-1.318 2.118h-3.952c-1.171 0-1.903-1.177-1.318-2.118z"/><circle cx="8.5" cy="9.5" r="1.5" fill="#fff"/>
    </svg>;
}
