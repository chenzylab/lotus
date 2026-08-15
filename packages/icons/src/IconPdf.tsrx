/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconPdf(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="M12.599.67a1 1 0 0 1 .608.289l4.166 4.167a1 1 0 0 1 .293.707v11.666c0 1.013-.82 1.834-1.833 1.834H4.166a1.834 1.834 0 0 1-1.833-1.834v-15c0-1.012.82-1.833 1.833-1.833H12.5zM7.5 6.5q-.089 0-.173.016l-.026.004-.048.011q-.024.005-.047.012a1 1 0 0 0-.31.16q-.016.012-.034.026A1 1 0 0 0 6.5 7.5v6.667a1 1 0 0 0 2 0v-2.335l4.001-.002a1 1 0 0 0 .999-1V7.5a1 1 0 0 0-1-1zm4 3.33-2.998.002L8.501 8.5H11.5z"/>
    </svg>;
}
