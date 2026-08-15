/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconFlag(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="M22 3.618v10.764a.92.92 0 0 1-.565.866C20.7 15.544 19.35 16 18 16c-2 0-3.5-.5-5-1a18 18 0 0 1-.84-.309C11.182 14.314 10.374 14 8 14c-1.268 0-2.268.179-3 .385V20.5a1.5 1.5 0 0 1-3 0V3.58c0-.359.19-.689.51-.853C3.57 2.179 6.08 1 8 1c2.5 0 3.19.31 4.148.685.26.102.532.208.852.315 1.5.5 3 1 5 1 .89 0 1.779-.198 2.492-.417.711-.22 1.508.292 1.508 1.035"/>
    </svg>;
}
