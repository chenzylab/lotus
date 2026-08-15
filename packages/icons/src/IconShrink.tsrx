/**
 * 图标资源移植自 Semi Design（MIT License），viewBox/path 数据保留，
 * 组件名与文件按 @lotus/icons 命名规范重写。详见 .claude/skills/semi-porting/SKILL.md。
 */
export function IconShrink(props: { class?: string; style?: Record<string, any> }) {
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
        <path fill="currentColor" d="M2.44 2.44a1.5 1.5 0 0 0 0 2.12L6.878 9H4a1.5 1.5 0 0 0 0 3h6.5a1.496 1.496 0 0 0 1.5-1.5V4a1.5 1.5 0 0 0-3 0v2.879l-4.44-4.44a1.5 1.5 0 0 0-2.12 0M20 12a1.5 1.5 0 0 1 0 3h-2.878l4.439 4.44a1.5 1.5 0 1 1-2.122 2.12L15 17.122V20a1.5 1.5 0 1 1-3 0v-6.5a1.49 1.49 0 0 1 .897-1.374c.184-.08.388-.126.603-.126z"/>
    </svg>;
}
