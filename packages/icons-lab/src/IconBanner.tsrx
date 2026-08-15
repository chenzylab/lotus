/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconBanner(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="#6A6F7F" d="M6 19h12v1H6z"/><rect width="2" height="22.263" x="7.942" y=".897" fill="#AAB2BF" rx="1" transform="rotate(10 7.942 .897)"/><rect width="2" height="22.312" x="14.085" y="1.229" fill="#AAB2BF" rx="1" transform="rotate(-10 14.085 1.229)"/><rect width="22" height="14" x="1" y="3" fill="#FBCD2C" rx="2"/><path fill="#324350" d="M4 6h16v2H4zM4 11h9v2H4z"/>
    </svg>;
}
