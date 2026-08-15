/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconWord(props: { class?: string; style?: Record<string, any> }) {
    return <svg
        viewBox="0 0 20 20"
        fill="none"
        width="1em"
        height="1em"
        class={props.class}
        style={props.style}
        aria-hidden={true}
        xmlns="http://www.w3.org/2000/svg"
    >
        <path fill="currentColor" d="M12.599.67a1 1 0 0 1 .608.289l4.166 4.167a1 1 0 0 1 .293.707v11.666c0 1.013-.82 1.834-1.833 1.834H4.166a1.834 1.834 0 0 1-1.833-1.834v-15c0-1.012.82-1.833 1.833-1.833H12.5zm.947 6.686a1 1 0 0 0-1.188.768l-.653 3.045-.807-1.615a1 1 0 0 0-1.717-.121l-.073.12L8.3 11.17l-.653-3.046a1 1 0 0 0-1.955.42l1.25 5.833a1 1 0 0 0 1.872.237l1.189-2.378 1.19 2.378a1 1 0 0 0 1.872-.237l1.25-5.833a1 1 0 0 0-.77-1.188"/>
    </svg>;
}
