/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconHeart(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="#F82C2C" fill-rule="evenodd" d="M20.5 13.985 12.015 5.5l.742-.743a6 6 0 1 1 8.486 8.486z" clip-rule="evenodd"/><path fill="#FF7D95" d="M11.243 4.757a6 6 0 1 0-8.486 8.486L12 22.485s5.183-5.168 8.5-8.485c1.3-1.253 1.84-2 2.16-3-2.66 3-4.16 1-10.645-5.5-.507-.508-.772-.743-.772-.743"/>
    </svg>;
}
